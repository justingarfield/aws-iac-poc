###############################
### Organizational Units (OUs)
###############################

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.current.roots[0].id
}

####################
### Shared Accounts
####################

# Also referred to as the "Security" account
resource "aws_organizations_account" "audit" {
  name      = "Audit"
  email     = "aws+audit@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_account" "backup_administrator" {
  name      = "Backup Administrator"
  email     = "aws+backup-administrator@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
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
