variable "iam_prefix" {
  description = "The name prefix for IAM Role and Policy"
  default     = "SecurityHubManage"
}

variable "admin_account_id" {
  description = "The AWS Account ID of the cross-account IAM Role"
}

variable "admin_iam_role" {
  description = "The AWS cross-account Role name that will be able to assume the SecurityHub Management Role"
  default     = "SecurityHubConfigDeployerRole"
}

variable "tags" {
  default = {}
}
