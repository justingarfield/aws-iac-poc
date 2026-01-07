# See: https://docs.aws.amazon.com/controltower/latest/userguide/configure-kms-keys.html

resource "aws_kms_key_policy" "centralized_logging" {
  key_id = aws_kms_key.centralized_logging.id
  policy = jsonencode({
    # See: https://github.com/hashicorp/terraform-provider-aws/issues/30232
    Version = "2012-10-17"
    Id      = "AWS Config KMS key policy"
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
        "Sid" : "Allow Config to use KMS for encryption",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "config.amazonaws.com"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        "Resource" : aws_kms_key.centralized_logging.arn
      },
      {
        "Sid" : "Allow CloudTrail to use KMS for encryption",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        "Resource" : aws_kms_key.centralized_logging.arn
        "Condition" : {
          "StringEquals" : {
            "aws:SourceArn" : "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/aws-controltower-BaselineCloudTrail"
          },
          "StringLike" : {
            "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "centralized_logging" {
  description             = "AWS Config KMS key"
  enable_key_rotation     = true
  multi_region            = false
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "centralized_logging" {
  name          = "alias/centralized_logging"
  target_key_id = aws_kms_key.centralized_logging.key_id
}
