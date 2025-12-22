import {
  to = aws_iam_role.aws_control_tower_admin
  id = "AWSControlTowerAdmin"
}

import {
  to = aws_iam_role.aws_control_tower_cloud_trail
  id = "AWSControlTowerCloudTrailRole"
}

import {
  to = aws_iam_role.aws_control_tower_config_aggregator_for_organizations
  id = "AWSControlTowerConfigAggregatorRoleForOrganizations"
}

import {
  to = aws_iam_role.aws_control_tower_stack_set
  id = "AWSControlTowerStackSetRole"
}

import {
  to = aws_iam_role_policy.aws_control_tower_admin
  id = "AWSControlTowerAdmin:AWSControlTowerAdminPolicy"
}

import {
  to = aws_iam_role_policy.aws_control_tower_stack_set
  id = "AWSControlTowerStackSetRole:AWSControlTowerStackSetRolePolicy"
}

import {
  to = aws_iam_role_policy_attachment.aws_config_role_for_organizations
  id = "AWSControlTowerConfigAggregatorRoleForOrganizations/arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

import {
  to = aws_iam_role_policy_attachment.aws_control_tower_cloud_trail_role_policy
  id = "AWSControlTowerAdmin/arn:aws:iam::aws:policy/service-role/AWSControlTowerCloudTrailRolePolicy"
}

import {
  to = aws_iam_role_policy_attachment.aws_control_tower_service_role_policy
  id = "AWSControlTowerAdmin/arn:aws:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
}

import {
  to = aws_organizations_account.audit
  id = "182138814237"
}

import {
  to = aws_organizations_account.backup_administrator
  id = "569148493463"
}

import {
  to = aws_organizations_account.central_backup
  id = "176545285433"
}

import {
  to = aws_organizations_account.log_archive
  id = "052032053611"
}

import {
  to = aws_organizations_organizational_unit.infrastructure
  id = "ou-xj34-tthjptsp"
}

import {
  to = aws_organizations_organizational_unit.sandbox
  id = "ou-xj34-mfdkqq58"
}

import {
  to = aws_organizations_organizational_unit.security
  id = "ou-xj34-zi15tm0r"
}

moved {
  from = aws_kms_key.this
  to   = aws_kms_key.backup
}

moved {
  from = aws_kms_key_policy.this
  to   = aws_kms_key_policy.backup
}
