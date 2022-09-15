locals {
  lambda_name = aws_lambda_function.tfc_workspaces_backup.function_name
  #  bucket_arn       = module.s3_bucket.s3_bucket_arn
  #  kms_arn          = aws_kms_key.tfc_workspace_backup.arn
  #apigw_invoke_url = module.api_gateway.default_apigatewayv2_stage_invoke_url
}

variable "lambda_name" {
  description = "The name of the lambda function"
  type        = string
  default     = "tfc-workspaces-backup"
}

variable "bucket_name" {
  description = "Bucket to save the backups"
  type        = string
}

variable "apigw_name" {
  description = "The name of the API gateway"
  type        = string
  default     = "tfc-workspaces-backup"
}

variable "notification_name" {
  description = "The notification name for the TFC notification"
  type        = string
  default     = "tfc-workspaces-backup"
}

variable "workspace_ids" {
  description = "List of the workspaces IDs to back up."
  type        = list(string)
}

# tflint-ignore: terraform_naming_convention
variable "TFE_TOKEN" {
  type        = string
  description = "Terraform Cloud Token"
}

variable "bucket_builds" {
  description = "Lambda Builds Bucket"
  type        = string
}
variable "lambda_s3_key" {
  description = "Lambda Build Key"
  type        = string
}


variable "tags" {
  description = "sdp-standard-tags object"
  type        = any
  validation {
    condition     = length(setintersection(keys(var.tags.aws_tags), ["CostCenter", "Environment", ])) == 2
    error_message = "ERROR: tags['aws_tags'] must contain 'CostCenter' and 'Environment' keys."
  }
  validation {
    condition     = length(setintersection(keys(var.tags), ["aws_tags", "env", "environment", ])) == 3
    error_message = "ERROR: tags must contain 'aws_tags', 'env', and 'environment' keys."
  }
}
