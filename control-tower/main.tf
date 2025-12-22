###############################
### Organizational Units (OUs)
###############################

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = var.organization_root_ou_id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = var.organization_root_ou_id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = var.organization_root_ou_id
}

###############################
### AWS Organizations Accounts
###############################

# Also referred to as the "Security" account
resource "aws_organizations_account" "audit" {
  name      = "Audit"
  email     = "aws+audit@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_account" "backup_administrator" {
  name      = "Backup Administrator"
  email     = "aws+backup-administrator@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

resource "aws_organizations_account" "central_backup" {
  name      = "Central Backup"
  email     = "aws+backup@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_account" "log_archive" {
  name      = "Log Archive"
  email     = "aws+log-archive@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}
/*
resource "aws_controltower_landing_zone" "this" {
  manifest_json = templatefile("${path.module}/landing-zone-manifest-4.0.json", {
    backup_admin_account_id         = aws_organizations_account.backup_administrator.id
    backup_kms_key_arn              = aws_kms_key.backup.arn
    central_backup_account_id       = aws_organizations_account.central_backup.id
    centralized_logging_account_id  = aws_organizations_account.log_archive.id
    centralized_logging_kms_key_arn = aws_kms_key.centralized_logging.arn
    config_account_id               = aws_organizations_account.audit.id
    config_kms_key_arn              = aws_kms_key.config.arn
    security_roles_account_id       = aws_organizations_account.audit.id
  })
  version = "4.0"
}
*/
