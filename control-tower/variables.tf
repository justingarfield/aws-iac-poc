variable "additional_governed_regions" {
  default     = [ "us-west-1" ]
  description = "Regions other than the 'Home Region' to govern with Control Tower."
  type        = set(string)
}
