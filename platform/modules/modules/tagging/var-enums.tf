//These are required in this major version and will break
//a plan/apply if not set.

variable "environment-enum" {
  type    = list(string)
  default = ["demo", "dev", "qa", "uat", "prod"]
}

variable "aws-account-type-enum" {
  type    = list(string)
  default = ["prod", "nonprod"]

}


variable "ci-owner-enum" {
  type    = list(string)
  default = ["raja", "manohar"]
}

variable "business-unit-enum" {
  type    = list(string)
  default = ["NubesOpus", "Clients"]
}

variable "enable-backup-enum" {
  type    = list(string)
  default = ["4am-6am-utc", "7am-9am-utc"]
}

variable "monitor-enum" {
  type    = list(string)
  default = ["false", "infra", "full"]

}
