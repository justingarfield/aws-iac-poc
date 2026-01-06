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

  depends_on = [aws_kms_replica_key.backup_replica]
}
