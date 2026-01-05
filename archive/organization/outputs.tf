output "organization_id" {
  description = "The Id of the AWS Organization."
  value       = aws_organizations_organization.this.id
}

output "root_ou_id" {
  description = "The Id of the AWS Organizations Root OU."
  value       = aws_organizations_organization.this.roots[0].id
}

output "root_ou_arn" {
  description = "The ARN of the AWS Organizations Root OU."
  value       = aws_organizations_organization.this.roots[0].arn
}
