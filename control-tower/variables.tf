variable "audit_account_id" {
  description = ""
  type        = string
}

variable "backup_admin_account_id" {
  description = ""
  type        = string
}

variable "central_backup_account_id" {
  description = ""
  type        = string
}

variable "centralized_logging_account_id" {
  description = ""
  type        = string
}

variable "organization_id" {
  description = "The Id of the AWS Organization."
  type        = string
}

variable "organization_root_ou_id" {
  description = "The Id of the AWS Organizations Root OU."
  type        = string
}
data.terraform_remote_state.control_tower_accounts.outputs.audit_account_id