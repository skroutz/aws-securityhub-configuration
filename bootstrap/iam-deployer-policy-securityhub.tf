data "aws_iam_policy_document" "user-policy-document" {
  dynamic "statement" {
    for_each = local.managed_aws_accounts
    content {
      sid     = "AccessSecurityHub${statement.value}"
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      effect  = "Allow"
      resources = [
        "arn:aws:iam::${statement.value}:role/${local.admin_iam_role}"
      ]
    }
  }
}


data "aws_iam_policy_document" "combined" {
  source_policy_documents = []
}

# Add ARN (module.user-policy.arn)to 'module.user-role.custom_role_policy_arns'
# to grant IAM Policy access to the CI/CD worker
module "user-policy" {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-policy?ref=v5.1.0"

  name   = local.iam-deployer-policy
  policy = data.aws_iam_policy_document.user-policy-document.json
}

