resource "aws_organizations_organization" "this" {
  # aws_service_access_principals = [
  #   "sso.amazonaws.com"
  # ]
  # enabled_policy_types = []
  # feature_set = "ALL"

  lifecycle {
    # See: https://docs.aws.amazon.com/organizations/latest/APIReference/API_EnableAWSServiceAccess.html
    ignore_changes = [aws_service_access_principals]
  }
}
