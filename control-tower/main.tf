resource "aws_controltower_landing_zone" "this" {
  manifest_json = templatefile("${path.module}/landing-zone-manifest-4.0.json", {
    backup_admin_account_id         = var.backup_admin_account_id
    backup_kms_key_arn              = aws_kms_key.backup.arn
    central_backup_account_id       = var.central_backup_account_id
    centralized_logging_account_id  = aws_organizations_account.log_archive.id
    centralized_logging_kms_key_arn = aws_kms_key.centralized_logging.arn
    config_account_id               = var.audit_account_id
    config_kms_key_arn              = aws_kms_key.config.arn
    security_roles_account_id       = var.audit_account_id
  })
  version = "4.0"
}
