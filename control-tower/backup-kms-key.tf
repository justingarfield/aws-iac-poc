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
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
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
            "aws:PrincipalOrgID" : "${var.organization_id}"
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
  deletion_window_in_days = 20
}
