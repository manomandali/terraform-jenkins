variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "vpc"
}

variable "realm" {
  description = "Realm the VPC will be deployed in (i.e prod,dev,qa,uat.)"
  default     = "dev"
}

variable "region" {
  description = "The region the VPC will be deployed in (i.e useast1, useast2, uswest1, uswest2)"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  default     = ""
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "public_bizwithai_subnets" {
  description = "A list of public bizwithai subnets inside the VPC"
  default     = 1
}

variable "private_bizwithai_subnets" {
  description = "A list of private bizwithai subnets inside the VPC"
  default     = 1
}

variable "bizwithai_database_subnets" {
  description = "A list of bizwithai database subnets"
  default     = 1

}

variable "create_bizwithai_database_subnet_group" {
  description = "Controls if bizwithai database subnet group should be created"
  default     = false
}

variable "azs" {
  description = "A list of availability zones in the region"
  default     = ["ap-south-1a"]
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_bizwithai_nat_gateway" {
  description = "Should be true if you want to provision bizwithai NAT Gateways for each of your private networks"
  default     = true
}

variable "reuse_nat_bizwithai_ips" {
  description = "Should be true if you don't want bizwithai EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_bizwithai_ids' variable"
  default     = false
}

variable "external_nat_ip_bizwithai_ids" {
  description = "List of bizwithai EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_bizwithai_ips)"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  default     = true
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

variable "public_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}

}

####################
# Other variables
####################

variable "role_name" {
  default = "github-terraform-role"
}

variable "account_number" {
  description = "The account number of the AWS acount"
}

variable "provider_region" {
  description = "AWS Region (i.e. us-east-1, us-west-1, etc.)"
  default     = "ap-south-1"

}
