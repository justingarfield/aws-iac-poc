output "audit_account_id" {
  description = "The Id of the Control Tower Audit account."
  value       = aws_organizations_account.audit.id
}

output "backup_admin_account_id" {
  description = "The Id of the Control Tower Backup Administrator account."
  value       = aws_organizations_account.backup_administrator.id
}

output "central_backup_account_id" {
  description = "The Id of the Control Tower Central Backup account."
  value       = aws_organizations_account.central_backup.id
}

output "centralized_logging_account_id" {
  description = "The Id of the Control Tower Centralized Logging account."
  value       = aws_organizations_account.log_archive.id
}
