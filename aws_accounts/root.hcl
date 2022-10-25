# root.hcl
locals {
  root_deployments_dir       = get_parent_terragrunt_dir()
  relative_deployment_path   = path_relative_to_include()
  deployment_path_components = compact(split("/", local.relative_deployment_path))

  tier  = local.deployment_path_components[0]
  stack = reverse(local.deployment_path_components)[0]

  accounts_ids = {
    "aws-account-alias"  = {"id" = "123456789012", "role_name" = "SecurityHubManageRole"},
  }
}

generate "constants" {
  path      = "constants.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
locals {

  project-name = "sec-hub-config"
  iam-resource-prefix = "SecurityHubConfig"

  account_alias = "${local.deployment_path_components[0]}"  // Directory name - Account Alias

  securityhub_configuration = yamldecode(file("${local.root_deployments_dir}/../securityhub-configuration.yaml"))

  cis_controls_disabled = local.securityhub_configuration[local.account_alias]["controls"]["CIS"]["disabled"]
  aws_controls_disabled = local.securityhub_configuration[local.account_alias]["controls"]["AWS"]["disabled"]
  pci_controls_disabled = local.securityhub_configuration[local.account_alias]["controls"]["PCI"]["disabled"]
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "eu-central-1"

  assume_role {
    // Assume appropriate SecurityHub Management IAM Role for each AWS account
    // as created from 'modules/terraform-aws-securityhub-manage-cross-account-iam-role'
    role_arn = "arn:aws:iam::${local.accounts_ids[local.tier]["id"]}:role/${local.accounts_ids[local.tier]["role_name"]}"
  }

  default_tags {
    tags = {
      DeployedFrom = "https://github.com/skroutz/aws-securityhub-configuration"
      ManagedBy    = "Terraform"
    }
  }
}
EOF
}

generate "state" {
  path      = "state.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {

    encrypt        = true

    # Values as generated from 'bootstrap/'
    region         = "<AWS_REGION>"
    bucket         = "<BUCKET_NAME>"
    dynamodb_table = "<DYNAMODB_NAME>"
    kms_key_id     = "<KMS_KEY_NAME>"

    key            = "tf-state/${path_relative_to_include()}/tfstate"
  }
}
EOF
}
