# See https://docs.aws.amazon.com/controltower/latest/userguide/lz-api-prereques.html#w2aac15c17c15c13

#######################
# AWSControlTowerAdmin
#######################

data "aws_iam_policy_document" "aws_control_tower_admin_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["controltower.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_control_tower_admin" {
  assume_role_policy = data.aws_iam_policy_document.aws_control_tower_admin_assume_role.json
  name               = "AWSControlTowerAdmin"
  path               = "/service-role/"
}

# The AWS IAM role AWSControlTowerAdmin requires an inline policy that includes permissions for ec2:DescribeAvailabilityZones, even when the AWSControlTowerServiceRolePolicy managed policy is attached.
# The AWSControlTowerAdmin role is designed with a specific inline policy, AWSControlTowerAdminPolicy, which grants the necessary permissions to configure IAM Identity Center (IdC) resources in member accounts enrolled with AWS Control Tower.
# This inline policy specifically includes the ec2:DescribeAvailabilityZones action, which is required for the proper functioning of the landing zone setup and management.
resource "aws_iam_role_policy" "aws_control_tower_admin" {
  name = "AWSControlTowerAdminPolicy"
  role = aws_iam_role.aws_control_tower_admin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeAvailabilityZones"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_control_tower_service_role_policy" {
  role       = aws_iam_role.aws_control_tower_admin.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
}

################################
# AWSControlTowerCloudTrailRole
################################

data "aws_iam_policy_document" "aws_control_tower_cloud_trail" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_control_tower_cloud_trail" {
  assume_role_policy = data.aws_iam_policy_document.aws_control_tower_cloud_trail.json
  name               = "AWSControlTowerCloudTrailRole"
  path               = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "aws_control_tower_cloud_trail_role_policy" {
  role       = aws_iam_role.aws_control_tower_cloud_trail.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSControlTowerCloudTrailRolePolicy"
}

##############################
# AWSControlTowerStackSetRole
##############################

data "aws_iam_policy_document" "aws_control_tower_stack_set" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudformation.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_control_tower_stack_set" {
  assume_role_policy = data.aws_iam_policy_document.aws_control_tower_stack_set.json
  name               = "AWSControlTowerStackSetRole"
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "aws_control_tower_stack_set" {
  name = "AWSControlTowerStackSetRolePolicy"
  role = aws_iam_role.aws_control_tower_stack_set.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iam::*:role/AWSControlTowerExecution"
      }
    ]
  })
}

######################################################
# AWSControlTowerConfigAggregatorRoleForOrganizations
#
# !!! THIS GOES AWAY WITH LANDING ZONE v4!
# ADDED HERE TO REFLECT EXISTING 3.3 LANDING ZONE
######################################################

data "aws_iam_policy_document" "aws_control_tower_config_aggregator_for_organizations" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_control_tower_config_aggregator_for_organizations" {
  assume_role_policy = data.aws_iam_policy_document.aws_control_tower_config_aggregator_for_organizations.json
  name               = "AWSControlTowerConfigAggregatorRoleForOrganizations"
  path               = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "aws_config_role_for_organizations" {
  role       = aws_iam_role.aws_control_tower_config_aggregator_for_organizations.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

# Not 100% sure if we need this or not...possibly not?
# https://docs.aws.amazon.com//controltower/latest/userguide/roles-how.html#config-role-for-organizations
/*
resource "aws_iam_role_policy" "aws_control_tower_admin" {
  name = "AWSControlTowerStackSetRolePolicy"
  role = aws_iam_role.aws_control_tower_stack_set.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "organizations:ListAccounts",
          "organizations:DescribeOrganization",
          "organizations:ListAWSServiceAccessForOrganization"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}
*/
