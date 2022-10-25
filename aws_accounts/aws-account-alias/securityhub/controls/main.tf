resource "aws_securityhub_standards_control" "aws" {
  count = length(local.aws_controls_disabled)

  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/aws-foundational-security-best-practices/v/1.0.0/${local.aws_controls_disabled[count.index]["id"]}"
  control_status        = "DISABLED"
  disabled_reason       = local.aws_controls_disabled[count.index]["reason"]
}

resource "aws_securityhub_standards_control" "cis" {
  count = length(local.cis_controls_disabled)

  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/cis-aws-foundations-benchmark/v/1.2.0/${local.cis_controls_disabled[count.index]["id"]}"
  control_status        = "DISABLED"
  disabled_reason       = local.cis_controls_disabled[count.index]["reason"]
}

resource "aws_securityhub_standards_control" "pci" {
  count = length(local.pci_controls_disabled)

  standards_control_arn = "arn:aws:securityhub:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:control/pci-dss/v/3.2.1/${local.pci_controls_disabled[count.index]["id"]}"
  control_status        = "DISABLED"
  disabled_reason       = local.pci_controls_disabled[count.index]["reason"]
}
