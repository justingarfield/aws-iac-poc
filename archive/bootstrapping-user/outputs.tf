output "virtual_mfa_device_base_32_string_seed" {
  description = "The base32 seed defined as specified in RFC3548."
  value       = aws_iam_virtual_mfa_device.this.base_32_string_seed
}

output "iam_user_temporary_password" {
  description = ""
  value       = aws_iam_user_login_profile.this.encrypted_password
}
