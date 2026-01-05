locals {
  # I've only added this reverse sort to handle staggered provisioning while fixing issues
  # Probably don't need this for the final end result...but would recommend sorting either way.
  sorted_ct_regions = reverse(sort(concat([data.aws_region.current.region], tolist(var.additional_governed_regions))))
}

resource "aws_controltower_landing_zone" "this" {
  manifest_json = templatefile("${path.module}/landing-zone-manifest-4.0.json", {
    backup_admin_account_id         = data.terraform_remote_state.control_tower_accounts.outputs.backup_admin_account_id
    backup_kms_key_arn              = aws_kms_key.backup.arn
    central_backup_account_id       = data.terraform_remote_state.control_tower_accounts.outputs.central_backup_account_id
    centralized_logging_account_id  = data.terraform_remote_state.control_tower_accounts.outputs.centralized_logging_account_id
    centralized_logging_kms_key_arn = aws_kms_key.centralized_logging.arn
    config_account_id               = data.terraform_remote_state.control_tower_accounts.outputs.audit_account_id
    config_kms_key_arn              = aws_kms_key.config.arn
    security_roles_account_id       = data.terraform_remote_state.control_tower_accounts.outputs.audit_account_id
    governed_regions                = jsonencode(local.sorted_ct_regions)
  })
  version = "4.0"

  depends_on = [ aws_kms_replica_key.backup_replica ]
}

/*
resource "aws_controltower_control" "this" {
  control_identifier = "arn:${data.aws_partition.current.partition}:controlcatalog:::control/cwlixshc8c8mw9qiwdw2z0zav"
  target_identifier = data.terraform_remote_state.control_tower_accounts.outputs.root_ou_arn

  parameters {
    key   = "AllowedRegions"
    value = jsonencode(["us-east-1"])
  }
}

"arn": "arn:aws:controltower:us-east-1:929751802101:enabledcontrol/4GDNOWNNR47ICRBH",
45:            "controlIdentifier": "arn:aws:controltower:us-east-1::control/AWS-GR_REGION_DENY",
46-            "targetIdentifier": "arn:aws:organizations::929751802101:ou/o-fpehutbqzb/ou-xj34-zi15tm0r",
47-            "statusSummary": {
48-                "status": "SUCCEEDED"
49-            },
*/
