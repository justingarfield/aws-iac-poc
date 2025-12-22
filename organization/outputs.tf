output "organizations_root_ou_id" {
  description = "The Id of the AWS Organizations Root OU."
  value       = aws_organizations_organization.this.roots[0].id
}
