data "aws_caller_identity" "current" {}

data "terraform_remote_state" "organization" {
  backend = "local"

  config = {
    path = "../organization/terraform.tfstate"
  }
}

data "aws_ssoadmin_instances" "this" {}

data "aws_partition" "current" {}
