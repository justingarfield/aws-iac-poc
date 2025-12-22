provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::929751802101:role/Bootstrapping"
    session_name = "justin@jgarfield.com"
  }
}
