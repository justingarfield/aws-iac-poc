# See: https://docs.aws.amazon.com/controltower/latest/userguide/backup-prerequisites.html
resource "aws_kms_key_policy" "config" {
  key_id = aws_kms_key.config.id
  policy = jsonencode({
    # See: https://github.com/hashicorp/terraform-provider-aws/issues/30232
    Version = "2012-10-17"
    Id      = "AWS Config KMS key policy"
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
        Sid    = "Allow AWS Config to use the key"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_key" "config" {
  description             = "AWS Config KMS key"
  enable_key_rotation     = true
  multi_region            = false # "The KMS key selected for the AWS CloudTrail integration must not be a multi-region key."
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "config" {
  name          = "alias/config"
  target_key_id = aws_kms_key.config.key_id
}
