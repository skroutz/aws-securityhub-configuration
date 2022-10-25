# For these resources to work it is needed to enable the
# SecurityHub for the deploying AWS Account
resource "aws_securityhub_standards_subscription" "aws" {
  count = local.securityhub_configuration[local.account_alias]["subscriptions"]["AWS"] ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_standards_subscription" "cis" {
  count = local.securityhub_configuration[local.account_alias]["subscriptions"]["CIS"] ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

resource "aws_securityhub_standards_subscription" "pci" {
  count = local.securityhub_configuration[local.account_alias]["subscriptions"]["PCI"] ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/pci-dss/v/3.2.1"
}
