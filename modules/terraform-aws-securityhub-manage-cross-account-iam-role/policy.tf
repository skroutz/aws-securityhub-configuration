data "aws_iam_policy_document" "this-policy" {
  statement {
    sid = "Read"
    actions = [
      "securityhub:Get*",
      "securityhub:List*",
      "securityhub:Describe*",
    ]
    resources = ["*"]
  }

  statement {
    sid = "Write"
    actions = [
      "securityhub:UpdateStandardsControl",
      "securityhub:BatchDisableStandards",
      "securityhub:BatchEnableStandards",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name = "${var.iam_prefix}Policy"

  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this-policy.json
}

