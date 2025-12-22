provider "aws" {
  default_tags {
    tags = {
      "managed-by" = "opentofu"
      "project"    = "aws-iac-poc"
    }
  }
}
