# Pre-Init

This module is responsible for creating AWS Resources:
- s3 bucket (for keeping Terraform remote backend)
- dynamoDB table (state locking table)

This module **must be** run first in a new environment, as other modules will use it's resources.

### State backend

The Terraform backend is `local`. State file should be commited to the repository
(excluded in the [.gitignore](/.gitignore.example) file).

## Procedures

### New Account Configuration Procedure

1. Set up AWS access for the user that will run Terraform
1. Create pre-init folder structure, e.g. `terraform/dev/pre-init/`
1. Set variables in the evironment directory, e.g. `terraform/dev/env.tfvars`
    1. `account_id` - AWS Account ID. If does not match the confugired AWS CLI credential's Account, Terraform would fail the validation step.
    1. `env` - Environment name (e.g. `stage`)
    1. `project` - Project name
    1. `region` - AWS Region
1. Set variables in the main file, e.g. `terraform/dev/pre-init/main.tf`
    1. `bucket_name` - The Terraform state bucket name for this environment
    1. `table_name` - DynamoDB table name, for Terraform state lock
1. Ensure AWS-CLI is configured
1. Ensure required version of Terraform
1. Run Terrafform in the pre-init folder
    1. `terraform init` - Initialize Terraform
    1. `terraform apply -var-file ../env.tfvars` - Apply changes
1. Remember to commit and push changes, the `.tfstate` file in particular
1. Note the output values, for use in other modules configuration (or use `terraform output` command later)

### New module in the Environment

Creating the infrastructure, using pre-defined [modules](../../modules/).

1. Create folder structure, e.g. `terraform/dev/network/`
1. Create or copy files from anoter environment, and set desired values for required variables, e.g. `terraform/dev/vm/main.tf`, especially
    1. `main.tf` - Terraform backend, e.g.

    ```hcl
    terraform {
        backend "s3" {
        bucket         = "terraform-state-aws-es-devops-cloud-wizard-5"
        dynamodb_table = "terraform-state-aws-es-devops-cloud-wizard-5"
        encrypt        = true
        key            = "terraform-state-aws-es-devops-cloud-wizard.module_name.tfstate"
        region         = "eu-central-1"
        }
    }
    ```

    1. `variables-env.tf` - Variables. Should be the same for the whole Environment
    1. `outputs.tf` - If you need to produce any outputs
    1. Ensure AWS CLI is configured
    1. Ensure required version of Terraform
    1. Run Terrafform in the environment folder
        1. `terraform init` - Initialize Terraform
        1. `terraform apply -var-file ../env.tfvars` - Apply changes

## Other info

### AWS CLI

To run Terraform, you must setup the AWS CLI. If you are using the AWS CLI for the first time, you
should do initial configuration (see: `aws configure help`).

Example config:

`~/.aws/config`

```ini
(...)

[profile your-project-dev]
region = eu-central-1
```

`~/.aws/credentials`

```ini
(...)

[your-project-dev]
aws_access_key_id = XXXXX...
aws_secret_access_key = XXXXX...
```

In terminal

```bash
export AWS_PROFILE=clicktrans-stage # Set profile name
aws configure list # Check configuration
aws sts get-caller-identity # Check identity
```

### Terraform version

You may need to change Terraform version to the one specified in the [`required_version`](main.tf) for this module. Recommended tools for daily operations: `tfenv`, `tfswitch`.

### Example file structure

```text
terraform
├── env
│   ├── env.tfvars
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables-env.tf
│   └── pre-init
│       ├── main.tf
│       ├── outputs.tf
│       ├── pre-init-state.tfstate
│       └── variables-env.tf
├── modules
│   ├── network
│   │   ├── (...)
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables-env.tf
│   │   ├── variables.tf
│   └── pre-init
|       └── (...)
```

<!-- REFERENCES -->

[TFS3]: https://www.terraform.io/language/settings/backends/s3
[TFLock]: https://www.terraform.io/language/state/locking
