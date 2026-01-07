data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "terraform_remote_state" "control_tower_prereqs" {
  backend = "local"

  config = {
    path = "../control-tower-prereqs/terraform.tfstate"
  }
}
