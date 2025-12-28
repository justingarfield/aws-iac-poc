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

data "aws_iam_policy_document" "root_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

###########################
### Audit - Shared Account
###########################

# Also referred to as the "Security" account
resource "aws_organizations_account" "audit" {
  name      = "Audit"
  email     = "aws+audit@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

### Audit - Shared Account --> Cross-Account Role Assumption for Role Creation

provider "aws" {
  alias = "ct_audit_account"

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.audit.id}:role/OrganizationAccountAccessRole"
    session_name = "justin@jgarfield.com"
  }

  default_tags {
    tags = {
      "managed-by" = "opentofu"
      "project"    = "aws-iac-poc"
    }
  }
}

resource "aws_iam_role" "audit" {
  provider = aws.ct_audit_account

  assume_role_policy = data.aws_iam_policy_document.root_assume_role.json
  name               = "AWSControlTowerExecution"
  description        = "Allows full account access for enrollment."
  path               = "/service-role/"
}

##########################################
### Backup Administrator - Shared Account
##########################################

resource "aws_organizations_account" "backup_administrator" {
  name      = "Backup Administrator"
  email     = "aws+backup-administrator@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

### Backup Administrator - Shared Account --> Cross-Account Role Assumption for Role Creation

provider "aws" {
  alias = "ct_backup_admin_account"

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.backup_administrator.id}:role/OrganizationAccountAccessRole"
    session_name = "justin@jgarfield.com"
  }

  default_tags {
    tags = {
      "managed-by" = "opentofu"
      "project"    = "aws-iac-poc"
    }
  }
}

resource "aws_iam_role" "backup_administrator" {
  provider = aws.ct_backup_admin_account

  assume_role_policy = data.aws_iam_policy_document.root_assume_role.json
  name               = "AWSControlTowerExecution"
  description        = "Allows full account access for enrollment."
  path               = "/service-role/"
}

####################################
### Central Backup - Shared Account
####################################

resource "aws_organizations_account" "central_backup" {
  name      = "Central Backup"
  email     = "aws+backup@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

### Central Backup - Shared Account --> Cross-Account Role Assumption for Role Creation

provider "aws" {
  alias = "ct_central_backup_account"

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.central_backup.id}:role/OrganizationAccountAccessRole"
    session_name = "justin@jgarfield.com"
  }

  default_tags {
    tags = {
      "managed-by" = "opentofu"
      "project"    = "aws-iac-poc"
    }
  }
}

resource "aws_iam_role" "central_backup" {
  provider = aws.ct_central_backup_account

  assume_role_policy = data.aws_iam_policy_document.root_assume_role.json
  name               = "AWSControlTowerExecution"
  description        = "Allows full account access for enrollment."
  path               = "/service-role/"
}

#################################
### Log Archive - Shared Account
#################################

resource "aws_organizations_account" "log_archive" {
  name      = "Log Archive"
  email     = "aws+log-archive@jgarfield.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

### Log Archive - Shared Account --> Cross-Account Role Assumption for Role Creation

provider "aws" {
  alias = "ct_log_archive_account"

  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.log_archive.id}:role/OrganizationAccountAccessRole"
    session_name = "justin@jgarfield.com"
  }

  default_tags {
    tags = {
      "managed-by" = "opentofu"
      "project"    = "aws-iac-poc"
    }
  }
}

resource "aws_iam_role" "log_archive" {
  provider = aws.ct_log_archive_account

  assume_role_policy = data.aws_iam_policy_document.root_assume_role.json
  name               = "AWSControlTowerExecution"
  description        = "Allows full account access for enrollment."
  path               = "/service-role/"
}
