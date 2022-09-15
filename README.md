# TFC Backup

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1 |
| aws | >= 4.0 |
| tfe | >= 0.35 |
| time | >= 0.8 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |
| tfe | >= 0.35 |
| time | >= 0.8 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| api\_gateway | terraform-aws-modules/apigateway-v2/aws | 2.1.0 |
| s3\_bucket | terraform-aws-modules/s3-bucket/aws | 2.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.tfc_backup_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.tfc_workspaces_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.tfc_workspace_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.tfc_workspaces_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.apigw_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [tfe_notification_configuration.tfc_workspaces_backup](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/notification_configuration) | resource |
| [time_sleep.wait_120_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.aws_lambda_trust_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tfc_backup_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tfc_backup_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_lambda_function.tfc_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_function) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| TFE\_TOKEN | Terraform Cloud Token | `string` | n/a | yes |
| bucket\_builds | Lambda Builds Bucket | `string` | n/a | yes |
| bucket\_name | Bucket to save the backups | `string` | n/a | yes |
| lambda\_s3\_key | Lambda Build Key | `string` | n/a | yes |
| tags | sdp-standard-tags object | `any` | n/a | yes |
| workspace\_ids | List of the workspaces IDs to back up. | `list(string)` | n/a | yes |
| apigw\_name | The name of the API gateway | `string` | `"tfc-workspaces-backup"` | no |
| lambda\_name | The name of the lambda function | `string` | `"tfc-workspaces-backup"` | no |
| notification\_name | The notification name for the TFC notification | `string` | `"tfc-workspaces-backup"` | no |

## Outputs

| Name | Description |
|------|-------------|
| apigw\_invoke\_url | The API gateway invocation url |
| bucket\_id | The ID of the s3 bucket used for the state backup |
<!-- END_TF_DOCS -->
