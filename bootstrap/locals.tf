locals {

  # ==============================================
  project-name = "sec-hub-config-state"
  iam-resource-prefix = "SecurityHubConfig"
  # ==============================================

  s3-bucket-name = "${local.project-name}-${data.aws_caller_identity.current.account_id}"
  dynamodb-name  = local.project-name

  iam-deployer-user    = "${local.iam-resource-prefix}DeployerUser"
  iam-deployer-role    = "${local.iam-resource-prefix}DeployerRole"
  iam-deployer-policy  = "${local.iam-resource-prefix}DeployerPolicy"

  securityhub-arn = "arn:aws:securityhub:*:${data.aws_caller_identity.current.account_id}:hub/default"

  admin_iam_role = "SecurityHubManageRole"
  managed_aws_accounts = [
    "123456789012", // aws-account-alias

    // To be filled with more 'SecurityHubManageRole' enabled Account IDs
  ]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
