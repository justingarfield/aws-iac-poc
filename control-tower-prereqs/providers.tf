provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::929751802101:role/bootstrapper/FoundationalBootstrapper"
    session_name = "justin@jgarfield.com"
  }

  default_tags {
    tags = {
      "managed-by" = "opentofu"
      "project"    = "aws-iac-poc"
    }
  }
}
