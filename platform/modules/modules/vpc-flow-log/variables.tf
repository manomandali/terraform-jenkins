variable "vpc_id" {
  description = "VPC ID to attach to"
}

variable "vpc_name" {
  description = "VPC name to attach to"
}

variable "traffic_type" {
  default     = "ALL"
  description = "The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL."
}

locals {
  default_log_group_name = "${var.vpc_name}_flow_log"
}

variable "log_group_name" {
  default     = ""
  description = "The name of the CloudWatch log group."
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
