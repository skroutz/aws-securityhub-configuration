AWS SecurityHub Configuration
----

This repository contains all needed Terraform/Terragrunt code and Workflows to configure AWS SecurityHub for multiple AWS Accounts.

## How to setup the repository

1) Run the `bootstrap/` directory instructions under the AWS Account that manages the SecurityHub service in your AWS Organization
(e.g account alias: `sechub-admin-account-alias`, account id: `012345678912`)
2) Populate `aws_accounts/root.hcl` using the values provided by the `bootstrap/` output 
3) Remove the `aws_accounts/aws-account-alias` directory along with its reference in `aws_accounts/root.hcl` and `securityhub-configuration.yaml` (as they are code samples)


## How to enroll a new AWS Account

1) Set an AWS Account Alias for the AWS Account to be managed (e.g account alias: `aws-account-alias`, account id: `123456789012`)
2) Create a `SecurityHubManageRole` by calling the [Terraform module](https://github.com/skroutz/aws-securityhub-configuration/tree/master/modules/terraform-aws-securityhub-manage-cross-account-iam-role) for the target AWS Account
3) Add the AWS Account ID in [`bootstrap/locals.tf`](https://github.com/skroutz/aws-securityhub-configuration/blob/master/bootstrap/locals.tf#L18) and run `terraform apply` in `bootstrap/` to update the Deployer IAM Role (provide cross-account access to the Role created in `2)`)
4) Add the Terraform code for the new AWS Account by running:
```bash
cp -r templates/_aws_account /aws_accounts/<AWS Account Alias>
```
The `<AWS Account Alias>` needs to be the AWS Account Alias created in `1)`

5) Add the YAML schema for the new AWS Account to `securityhub-configuration.yaml` [following this template](https://github.com/skroutz/aws-securityhub-configuration/blob/master/templates/account-configuration.yaml), and changing the `<AWS-ACCOUNT-ALIAS>` to the AWS Account Alias created in `1)`

6) Update the `aws_accounts/root.hcl` `accounts_ids` local parameter with an entry as follows:
```
  accounts_ids = {
    [...]
    "aws-account-alias"  = {"id" = "123456789012", "role_name" = "SecurityHubManageRole"},
  }
``` 

7) Update the last section of this `README.md` file (optional - for housekeeping).

## How to use

The only moving part in this repository after setup is the [`securityhub-configuration.yaml`](https://github.com/skroutz/aws-securityhub-configuration/blob/master/securityhub-configuration.yaml) file.
This file contains a YAML schema for each AWS Account set up with this repository. The schema looks as below and is explained in comments:

```yaml
# The Alias for the AWS Account - can be set/shown in console through IAM > Dashboard
aws-account-alias:
  # Enables/Disables Standards. Toggling to 'false' results in not showing issues from specific Ruleset
  subscriptions:
    CIS: true
    AWS: true
    PCI: true
  # Independent management of specific rules - per Ruleset.
  controls:
    AWS:
      disabled:     # List that accepts {"id":"...", "reason":"..."} maps
      - id: "EC2.19"        # 'Security groups should not allow unrestricted access to ports with high risk'
        reason: "Test AWS"  # Mandatory reason to disable this check for this AWS Account. Empty or no 'reason' key will fail
    CIS:
      disabled: []	# Exactly as above. IDs look like `1.7`
    PCI:
      disabled: []	# Exactly as above. IDs look like `PCI.Lambda.1`
```

Changing and commiting this file will trigger a [`terragrunt run-all plan`](https://github.com/skroutz/aws-securityhub-configuration/blob/master/.github/workflows/plan-on-push.yml) on PR and [`terragrunt run-all apply`](https://github.com/skroutz/aws-securityhub-configuration/blob/master/.github/workflows/apply-on-merge.yaml) on merge with `main` keeping the state locked and consistent.

### *No changes to other files are needed to manage SecurityHub*

---

## How it works

The IAM Role assumed by the CI/CD Workflow (IAM Policy defined [here](https://github.com/skroutz/aws-securityhub-configuration/blob/master/bootstrap/iam-deployer-policy-securityhub.tf)) can assume cross-account IAM Roles that can access SecurityHub components for their respective AWS Accounts.

Specifically, it can assume out-of-the-box IAM Roles with ARNs like `arn:aws:iam::<AWS Account ID>:role/SecurityHubManageRole` for all AWS Account IDs [listed in `bootstrap/locals.tf`](https://github.com/skroutz/aws-securityhub-configuration/blob/master/bootstrap/locals.tf#L18).

Such IAM Roles are created using [this Terraform module](https://github.com/skroutz/aws-securityhub-configuration/tree/master/modules/terraform-aws-securityhub-manage-cross-account-iam-role), tailored for this use-case, as follows:

```hcl
module "role"{
  source = "../../modules/terraform-aws-securityhub-manage-cross-account-iam-role"

  admin_account_id = "012345678912"                  //  <-- AWS 'sechub-admin-account-alias' account's ID       - not to be changed
  admin_iam_role   = "SecurityHubConfigDeployerRole" //  <-- Repository's deployer IAM Role defined in bootstrap - not to be changed

  tags = {
      DeployedFrom = "https://github.com/skroutz/aws-securityhub-configuration"
      ManagedBy    = "Terraform"
  }
}
```

This module can be used in AFT repositories to provision the appropriate IAM Role to all globally provisioned accounts (https://docs.aws.amazon.com/controltower/latest/userguide/aft-account-customization-options.html).


## Managed AWS Accounts

* `aws-account-alias` - `123456789012`
