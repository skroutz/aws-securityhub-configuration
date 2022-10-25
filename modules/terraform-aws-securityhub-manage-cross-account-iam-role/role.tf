data "aws_iam_policy_document" "this-role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.admin_account_id}:role/${var.admin_iam_role}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.iam_prefix}Role"
  assume_role_policy = data.aws_iam_policy_document.this-role.json

  tags = var.tags
}
