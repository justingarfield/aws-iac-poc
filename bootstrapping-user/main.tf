resource "aws_iam_group" "this" {
  name = "FoundationalBootstrapper"
  path = "/bootstrapper/"
}

resource "aws_iam_group_policy_attachment" "this" {
  group      = aws_iam_group.this.name
  policy_arn = "arn:aws:iam::aws:policy/SignInLocalDevelopmentAccess"
}

resource "aws_iam_policy" "iam" {
  name        = "FoundationalBootstrapper-ChangePassword"
  path        = "/bootstrapper/"
  description = "Allows the Foundational Bootstrapper to change its own password via the AWS Console."

  policy = templatefile("${path.module}/iam-changepassword-bootstrapping-policy.json", {
    foundational_bootstrapper_arn = aws_iam_user.this.arn
    current_account_id            = data.aws_caller_identity.current.account_id
    current_partition             = data.aws_partition.current.partition
  })
}

resource "aws_iam_group_policy_attachment" "iam" {
  group      = aws_iam_group.this.name
  policy_arn = aws_iam_policy.iam.arn
}

resource "aws_iam_user" "this" {
  #checkov:skip=CKV_AWS_273:This is a foundational bootstrapping account
  #checkov:skip=CKV2_AWS_22:This is a foundational bootstrapping account
  name = "FoundationalBootstrapper"
  path = "/bootstrapper/"
}

resource "aws_iam_user_group_membership" "this" {
  user = aws_iam_user.this.name

  groups = [
    aws_iam_group.this.name
  ]
}

resource "aws_iam_virtual_mfa_device" "this" {
  virtual_mfa_device_name = "FoundationalBootstrapper"
  path                    = "/bootstrapper/"
}

resource "aws_iam_user_login_profile" "this" {
  user                    = aws_iam_user.this.name
  password_reset_required = true
  pgp_key                 = "keybase:${var.keybase_username}"
  password_length         = 24
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.this.arn]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "FoundationalBootstrapper"
  path               = "/bootstrapper/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "organizations" {
  name        = "FoundationalBootstrapper-Organizations"
  path        = "/bootstrapper/"
  description = "Allows the Foundational Bootstrapper to provision AWS Organizations."

  policy = file("${path.module}/organizations-bootstrapping-policy.json")
}

resource "aws_iam_policy" "control_tower" {
  name        = "FoundationalBootstrapper-ControlTower"
  path        = "/bootstrapper/"
  description = "Allows the Foundational Bootstrapper to provision AWS Control Tower."

  policy = templatefile("${path.module}/controltower-bootstrapping-policy.json", {
    current_account_id = data.aws_caller_identity.current.account_id
    current_partition  = data.aws_partition.current.partition
  })
}

resource "aws_iam_role_policy_attachment" "organizations" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.organizations.arn
}

resource "aws_iam_role_policy_attachment" "control_tower" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.control_tower.arn
}

resource "aws_iam_role_policy_attachment" "control_tower" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSControlTowerIdentityCenterManagementPolicy"
}
