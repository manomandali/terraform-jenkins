//These are required in this major version and will break
//a plan/apply if not set.
variable "name" {
  type = string
}

variable "application-name" {
  type = string
}

variable "product" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws-account-type" {
  type = string
}

variable "team" {
  type = string
}

variable "contact" {
  type = string
}

variable "ci-owner" {
  type = string
}

variable "business-unit" {
  type = string
}

variable "repository" {
  type = string
}

variable "enable-backup" {
  type    = string
  default = "4am-6am-utc"
}

variable "offhours" {
  type = string
}

variable "tf-state-bucket" {
  type = string
}

variable "tf-state-key" {
  type = string
}

//These are optional and will be conditionally included if populated
variable "cost-center" {
  type    = string
  default = ""
}

variable "issue-tracking" {
  type    = string
  default = ""
}

variable "monitor" {
  type    = string
  default = ""
}
