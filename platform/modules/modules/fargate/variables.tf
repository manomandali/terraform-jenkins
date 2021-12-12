variable "account_alias" {
  description = "account where resources are being provisioned"
}

variable "profile" {
  description = "profile of aws account where resources are being provisioned"
}

variable "realm" {
  description = "Value to say whether the environment is demo, dev, prod, or something else."
  default     = "demo"
}

variable "region" {
  description = "AWS Region (i.e. useast1, uswest1, etc.)"
  default     = "useast1"
}

variable "provider_region" {
  description = "AWS Region (i.e. us-east-1, us-west-1, etc.)"
  default     = "ap-south-1"
}

variable "azs" {
  description = "List of availability zones you wish to depoly the VPC to"
  type        = list(string)
  default     = ["ap-south-1a"]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "phz_owner" {
  description = "VPC owner of the private hosted zone"
  default     = "true"

}

variable "tf-state-bucket" {
  description = "S3 bucket that is used to store remote state, bizwithai-admin-terraform"
  default     = "bizwithai-admin-terraform"
}

variable "tf-state-key" {
  description = "S3 bucket key used by the remote state, platform/roots"
  default     = "platform/roots"
}

variable "role_name" {
  default = "github-terraform-role"
}

variable "account_number" {
  description = "The account number of the AWS acount"
}

variable "name" {
  description = "required tag, the app name for naming resources"
  default     = "network-module"
}

variable "application-name" {
  description = "required tag, the human readable app name"
  default     = "Network Module"
}

variable "product" {
  description = "required tag, the product suite"
  default     = "network-module"
}

variable "environment" {
  description = "required tag, the enviroment this resource id used as, ie dev vs prod"
  default     = ""
}

variable "contact" {
  description = "required tag, the email for the app owner"
  default     = "raja@nubesopus.com"
}

variable "business-unit" {
  type    = string
  default = "infra-services"
}

variable "repository" {
  type    = string
  default = "platform/modules"
}

variable "aws-account-type" {
  description = "Account type used for tagging module (prod or nonprod)"
  default     = "nonprod"

}

variable "aws-account-type-enum" {
  description = "Account type enums used for tagging module (prod or nonprod)"
  type        = list(string)
  default     = ["prod", "nonprod"]
}


variable "cluster_version" {
  type    = string
  default = "1.20"
}

variable "network_remote_state_key" {
default = "platform/roots"
}