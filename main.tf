# API GW

module "api_gateway" {
  depends_on = [aws_lambda_function.tfc_workspaces_backup]
  source     = "terraform-aws-modules/apigateway-v2/aws"
  version    = "2.1.0"

  name                   = var.apigw_name
  description            = "tfe-backup"
  protocol_type          = "HTTP"
  create_api_domain_name = false

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Routes and integrations
  integrations = {
    "POST /${aws_lambda_function.tfc_workspaces_backup.function_name}" = {
      lambda_arn             = aws_lambda_function.tfc_workspaces_backup.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = aws_lambda_function.tfc_workspaces_backup.arn
    }
  }

  tags = var.tags.aws_tags
}

# Lambda


resource "aws_lambda_function" "tfc_workspaces_backup" {
  function_name = var.lambda_name
  s3_bucket     = var.bucket_builds
  s3_key        = var.lambda_s3_key
  handler       = "main"
  runtime       = "go1.x"
  memory_size   = 128
  timeout       = 10
  role          = aws_iam_role.tfc_workspaces_backup.arn

  environment {
    variables = {
      TF_TOKEN = var.TFE_TOKEN
      BUCKET   = var.bucket_name
    }
  }

  tags = var.tags.aws_tags
}

resource "aws_iam_role" "tfc_workspaces_backup" {
  name                = "role-lambda-tfc-backup"
  assume_role_policy  = data.aws_iam_policy_document.aws_lambda_trust_policy.json
  managed_policy_arns = [aws_iam_policy.tfc_backup_lambda_policy.arn]

  tags = var.tags.aws_tags
}

data "aws_iam_policy_document" "tfc_backup_lambda_policy" {
  statement {
    sid = "AllowLogging"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "PutObject"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    effect = "Allow"
    resources = [
      module.s3_bucket.s3_bucket_arn,
      "${module.s3_bucket.s3_bucket_arn}/*",
    ]
  }
  statement {
    sid = "AllowKms"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    effect = "Allow"
    resources = [
      aws_kms_key.tfc_workspace_backup.arn
    ]
  }
}


resource "aws_iam_policy" "tfc_backup_lambda_policy" {
  policy = data.aws_iam_policy_document.tfc_backup_lambda_policy.json
}

resource "aws_kms_key" "tfc_workspace_backup" {
  description             = "tfc-workspace-backup"
  deletion_window_in_days = 10
}

resource "aws_lambda_permission" "apigw_lambda" {
  depends_on    = [module.api_gateway.apigatewayv2_api_execution_arn]
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tfc_workspaces_backup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = join("", [module.api_gateway.apigatewayv2_api_execution_arn, "/*/*/", aws_lambda_function.tfc_workspaces_backup.function_name])
}


# S3


data "aws_iam_policy_document" "tfc_backup_s3_policy" {
  statement {
    sid = "AllowLambda"
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
    resources = [
      module.s3_bucket.s3_bucket_arn,
      "${module.s3_bucket.s3_bucket_arn}/*",
    ]

  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.2.0"

  bucket = var.bucket_name
  acl    = "private"
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.tfc_workspace_backup.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning = {
    enabled = true
  }
  object_lock_configuration = {
    object_lock_enabled = "Enabled"
  }
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  # Bucket policies
  attach_policy = true
  policy        = data.aws_iam_policy_document.tfc_backup_s3_policy.json

  tags = var.tags.aws_tags
}


# Workspaces

resource "tfe_notification_configuration" "tfc_workspaces_backup" {
  depends_on       = [time_sleep.wait_120_seconds]
  for_each         = toset(var.workspace_ids)
  name             = var.notification_name
  enabled          = true
  destination_type = "generic"
  triggers         = ["run:completed", "run:errored"]
  url              = join("", [module.api_gateway.default_apigatewayv2_stage_invoke_url, aws_lambda_function.tfc_workspaces_backup.function_name])
  workspace_id     = each.value
}


# There is a delay between the API GW is deployed and the availability of this endpoint, without this delay,
# the tfe_notification_configuration is going to fail at the moment of check the endpoint
resource "time_sleep" "wait_120_seconds" {
  depends_on      = [aws_lambda_permission.apigw_lambda, module.api_gateway, data.aws_lambda_function.tfc_backup]
  create_duration = "120s"
}
