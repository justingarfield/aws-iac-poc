data "aws_ssoadmin_instances" "this" {}

locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

resource "aws_identitystore_user" "this" {
  identity_store_id = local.identity_store_id
  display_name      = "Justin Garfield"
  user_name         = "justin@jgarfield.com"

  name {
    family_name = "Garfield"
    given_name  = "Justin"
  }
}

resource "aws_identitystore_group" "this" {
  identity_store_id = local.identity_store_id
  display_name      = "MyGroup"
  description       = "Some group name"
}

resource "aws_identitystore_group_membership" "this" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this.group_id
  member_id         = aws_identitystore_user.this.user_id
}
