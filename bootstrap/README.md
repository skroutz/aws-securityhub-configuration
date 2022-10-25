# Terraform Bootstrap

----

This directory handles all needed infrastructure to initialise the state of a AWS Terragrunt Repository,
along with appropriate - least-privilege - IAM Policies, both to securely access the Terraform State Backend,
and to work with automation.


## Contents

### Terraform State Backend

`aws-resources.tf`
* S3 Bucket
* KMS key to encrypt Terraform State files
* DynamoDB table to use as State lock
* IAM Policy to appropriately access the above

### Automation

`iam-deployer.tf`
* IAM User
* IAM User Credentials
* IAM Role that can only be assumed by the created IAM User

`iam-deployer-policy-*.tf`

* IAM Policies that enables fine-grained access to AWS Resources managed by this repository

## Usage

This bootstrap can be configured by modifying only the `locals.tf` and `provider.tf` files.

### Resource Naming

Created AWS resources are all named using the `project-name` and `iam-resource-prefix` locals (in `locals.tf`), so changing these is sufficient to create uniquely named resources.

### Resource Tagging

All created resources in AWS need to be tagged with specific fields.
The fields are centrally configured using Terraform provider's `default_tags`, and need to be set in `provider.tf`.

### Deployment

The whole directory needs to get deployed as below (using an Administrator IAM Role for the deploying account[s]):

```bash

# First create the user
terraform apply -target module.user

# Then the rest of the resources
terraform apply

# Display the sensitive output values
terraform output -json
````

The Terraform output `aws-deployer` contains IAM User Credentials and the name of an IAM Role that need to be set in Github Secrets.


The `tf-state-resources` Terraform output is needed to create a Terraform State Backend block as below:

```terraform
terraform {
  backend "s3" {

    encrypt        = true

    # Values as generated from 'bootstrap/'
    region         = "<AWS_REGION>"
    bucket         = "<BUCKET_NAME>"
    dynamodb_table = "<DYNAMODB_NAME>"
    kms_key_id     = "<KMS_KEY_NAME>"

    key            = "tf-state/<repository-name>"
  }
}
```
