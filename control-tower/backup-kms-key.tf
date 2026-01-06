# See: https://docs.aws.amazon.com/controltower/latest/userguide/backup-prerequisites.html
resource "aws_kms_key_policy" "backup" {
  key_id = aws_kms_key.backup.id
  policy = jsonencode({
    # See: https://github.com/hashicorp/terraform-provider-aws/issues/30232
    Version = "2012-10-17"
    Id      = "AWS Backup KMS key policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the KMS key for organization"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        },
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GetKeyPolicy",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:PrincipalOrgID" : data.aws_organizations_organization.current.id
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "backup" {
  description             = "AWS Backup KMS key"
  enable_key_rotation     = true
  multi_region            = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "backup" {
  name          = "alias/backup"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_kms_replica_key" "backup_replica" {
  # We have to create a Key Replica in every Region we operate in, 
  # so that Control Tower and manage centralized backups properly.
  for_each = var.additional_governed_regions
  region   = each.value

  description             = "AWS Backup KMS key replica"
  deletion_window_in_days = 7
  primary_key_arn         = aws_kms_key.backup.arn
}

resource "aws_kms_alias" "backup_replica" {
  for_each = var.additional_governed_regions
  region   = each.value

  name          = "alias/backup"
  target_key_id = aws_kms_replica_key.backup_replica[each.key].key_id
}

# See: https://docs.aws.amazon.com/controltower/latest/userguide/backup-prerequisites.html
resource "aws_kms_key_policy" "backup_replica" {
  for_each = var.additional_governed_regions
  region   = each.value

  key_id = aws_kms_replica_key.backup_replica[each.key].key_id
  policy = jsonencode({
    # See: https://github.com/hashicorp/terraform-provider-aws/issues/30232
    Version = "2012-10-17"
    Id      = "AWS Backup KMS key replica policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow use of the KMS key for organization"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        },
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GetKeyPolicy",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          "StringEquals" : {
            "aws:PrincipalOrgID" : data.aws_organizations_organization.current.id
          }
        }
      }
    ]
  })
}
