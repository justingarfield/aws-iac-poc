removed {
  from = aws_iam_role.aws_control_tower_admin
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role.aws_control_tower_cloud_trail
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role.aws_control_tower_config_aggregator_for_organizations
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role.aws_control_tower_stack_set
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role_policy.aws_control_tower_admin
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role_policy.aws_control_tower_stack_set
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role_policy_attachment.aws_config_role_for_organizations
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role_policy_attachment.aws_control_tower_cloud_trail_role_policy
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_iam_role_policy_attachment.aws_control_tower_service_role_policy
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_account.audit
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_account.backup_administrator
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_account.central_backup
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_account.log_archive
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_organizational_unit.infrastructure
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_organizational_unit.sandbox
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_organizations_organizational_unit.security
  lifecycle {
    destroy = false
  }
}

moved {
  from = aws_kms_key.this
  to   = aws_kms_key.backup
}

moved {
  from = aws_kms_key_policy.this
  to   = aws_kms_key_policy.backup
}
/*
import {
  to = aws_controltower_landing_zone.this
  id = "1931KSSHIHLNIUXQ"
}

import {
  provider = aws.us_west_1

  to = aws_kms_replica_key.backup_replica["us-west-1"]
  id = "mrk-6b99a235fdb14f2ba2b04e2f3c155439"
}
*/
