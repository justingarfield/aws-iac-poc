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

########################
### IAM Identity Center
########################
/*
locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  identity_store_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

resource "aws_identitystore_user" "this" {
  identity_store_id = local.identity_store_id
  display_name      = "${var.user_given_name} ${var.user_family_name}"
  user_name         = var.user_email

  name {
    family_name = var.user_family_name
    given_name  = var.user_given_name
  }
}

resource "aws_identitystore_group" "this" {
  identity_store_id = local.identity_store_id
  display_name      = "FoundationalBootstrapper"
  description       = "Used by the Foundational Bootstrapper process to provision AWS Control Tower."
}

resource "aws_identitystore_group_membership" "this" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this.group_id
  member_id         = aws_identitystore_user.this.user_id
}

resource "aws_ssoadmin_permission_set" "this" {
  name             = "FoundationalBootstrapper"
  description      = "Used by the Foundational Bootstrapper process to provision AWS Control Tower."
  instance_arn     = local.identity_store_arn
}

resource "aws_ssoadmin_account_assignment" "audit" {
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  principal_id   = aws_identitystore_group.this.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.audit.id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "backup_administrator" {
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  principal_id   = aws_identitystore_group.this.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.backup_administrator.id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "central_backup" {
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  principal_id   = aws_identitystore_group.this.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.central_backup.id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "log_archive" {
  instance_arn       = local.identity_store_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn

  principal_id   = aws_identitystore_group.this.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.log_archive.id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  # Adding an explicit dependency on the account assignment resource will
  # allow the managed attachment to be safely destroyed prior to the removal
  # of the account assignment.
  depends_on = [
    aws_ssoadmin_account_assignment.audit,
    aws_ssoadmin_account_assignment.backup_administrator,
    aws_ssoadmin_account_assignment.central_backup,
    aws_ssoadmin_account_assignment.log_archive
  ]

  instance_arn       = local.identity_store_arn
  managed_policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}
*/
