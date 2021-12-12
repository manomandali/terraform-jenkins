AWS VPC Terraform module
========================

Terraform module which creates VPC resources on AWS.

These types of resources are supported:

* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Subnet](https://www.terraform.io/docs/providers/aws/r/subnet.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [Route table](https://www.terraform.io/docs/providers/aws/r/route_table.html)
* [Internet Gateway](https://www.terraform.io/docs/providers/aws/r/internet_gateway.html)
* [NAT Gateway](https://www.terraform.io/docs/providers/aws/r/nat_gateway.html)
* [VPC Endpoint](https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html) (S3 and DynamoDB)
* [RDS DB Subnet Group](https://www.terraform.io/docs/providers/aws/r/db_subnet_group.html)
* [Main VPC Routing Table](https://www.terraform.io/docs/providers/aws/r/main_route_table_assoc.html)
* [Default VPC Routing Table](https://www.terraform.io/docs/providers/aws/r/default_route_table.html)
* [Default VPC](https://www.terraform.io/docs/providers/aws/r/default_vpc.html)

Network Diagrams
===============

## Network Diagram
![Infrastructure Overview](diagrams/DD-Dev-Infra-Architecture.png)

## Account Diagram
![Infrastructure Overview](diagrams/dd-aws-accounts.png)

## VPC Diagram

![Infrastructure Overview](diagrams/vpc-diagram.png)

Provider
========

Terraform is used to create, manage, and update infrastructure resources such as physical machines, VMs, network switches, containers, and more. Almost any infrastructure type can be represented as a resource in Terraform.

The Amazon Web Services (AWS) provider is used to interact with the many resources supported by AWS. The provider needs to be configured with the proper credentials before it can be used.

* [AWS Provider](https://www.terraform.io/docs/providers/aws/)

We are using GitHub actions to deploy the network module to deploy the infrastructure via a pull request

**Backends and Remote State**

```hcl
provider "aws" {
  region = "${var.provider_region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/${var.role_name}"
  }
}
```



## Backends
A "backend" in Terraform determines how state is loaded and how an operation such as apply is executed. This abstraction enables non-local file state storage, remote execution, etc.

By default, Terraform uses the "local" backend, which is the normal behavior of Terraform you're used to. This is the backend that was being invoked throughout the [introduction](https://www.terraform.io/intro/index.html).

* [Backends](https://www.terraform.io/docs/backends/index.html)

## Remote State

By default, Terraform stores state locally in a file named "terraform.tfstate". Because this file must exist, it makes working with Terraform in a team complicated since it is a frequent source of merge conflicts. Remote state helps alleviate these issues.

With remote state, Terraform stores the state in a remote store. Terraform supports storing state in Terraform Enterprise, Consul, S3, and more.

Remote state is a feature of backends. Configuring and using backends is easy and you can get started with remote state quickly. If you want to migrate back to using local state, backends make that easy as well.

* [Remote State](https://www.terraform.io/docs/state/remote.html)
* [data source terraform_remote_state](https://www.terraform.io/docs/providers/terraform/d/remote_state.html)

# Network Module

## Backend
When using terraform [workspaces](https://www.terraform.io/docs/backends/types/s3.html) the workspace key will automatically prepend before the key ie **env:\workspace**. Module will be deployed with a workspace that matches the tfvars. State is store in S3 bucket in bizwithai-admin account in ap-south-1

```hcl
terraform {
  backend "s3" {
    bucket  = "bizwithai-admin-terraform"
    key     = "platform/roots"
    region  = "ap-south-1"
    profile = "bizwithai-admin"
  }
}
```

## Usage
```hcl
module "vpc" {
  source = "../modules/network/"

  realm                           = "${var.realm}"
  region                          = "${var.region}"
  name                            = "vpc"
  cidr                            = "${var.new_vpc_cidr_block}"
  azs                             = ["${var.azs}"]
  public_subnets                  = "${var.subnet_count}"
  private_subnets                 = "${var.subnet_count}"
  database_subnets                = "${var.subnet_count}"
  create_database_subnet_group    = true
  enable_nat_gateway              = true
  account_number                  = "${var.account_number}"

  tags = {
    Terraform       = "true"
    Environment     = "${var.realm}"
    tf-state-bucket = "${var.tf-state-bucket}"
    tf-state-key    = "${var.tf-state-key}"
    tf-workspace    = "${terraform.workspace}"
  }

  database_subnet_tags = {
    Tier = "data"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| account_number | The account number of the AWS acount | string | - | yes |
| azs | A list of availability zones in the region | list | `<list>` | no |
| cidr | The CIDR block for the VPC | string | `` | no |
| create_database_subnet_group | Controls if database subnet group should be created | string | `true` | no |
| database_subnet_tags | Additional tags for the database subnets | map | `<map>` | no |
| database_subnets | A list of database subnets | string | `0` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | string | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | string | `true` | no |
| enable_nat_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | string | `false` | no |
| enable_s3_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | string | `false` | no |
| external_nat_ip_ids | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips) | list | `<list>` | no |
| instance_tenancy | A tenancy option for instances launched into the VPC | string | `default` | no |
| map_public_ip_on_launch | Should be false if you do not want to auto-assign public IP on launch | string | `true` | no |
| name | Name to be used on all the resources as identifier | string | `vpc` | no |
| private_route_table_tags | Additional tags for the private route tables | map | `<map>` | no |
| private_subnet_tags | Additional tags for the private subnets | map | `<map>` | no |
| private_subnets | A list of private subnets inside the VPC | string | `0` | no |
| provider_region | AWS Region (i.e. us-east-1, us-west-1, etc.) | string | `us-east-1` | no |
| public_route_table_tags | Additional tags for the public route tables | map | `<map>` | no |
| public_subnet_tags | Additional tags for the public subnets | map | `<map>` | no |
| public_subnets | A list of public subnets inside the VPC | string | `0` | no |
| realm | Realm the VPC will be deployed in (i.e prod,dev,qa,test,etc.) | string | `dev` | no |
| region | The region the VPC will be deployed in (i.e useast1, useast2, uswest1, uswest2) | string | - | yes |
| reuse_nat_ips | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable | string | `false` | no |
| role_name | - | string | `atlantis-terraform-role` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |
| vpc_tags | Additional tags for the VPC | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| account_id | - |
| database_subnet_group | ID of database subnet group |
| database_subnets | List of IDs of database subnets |
| database_subnets_az | List of the availability zones of database subnets |
| database_subnets_cidr_blocks | List of cidr_blocks of database subnets |
| default_network_acl_id | The ID of the default network ACL |
| default_route_table_id | The ID of the default route table |
| default_security_group_id | The ID of the security group created by default on VPC creation |
| igw_id | The ID of the Internet Gateway |
| nat_ids | List of allocation ID of Elastic IPs created for AWS NAT Gateway |
| nat_public_ips | List of public Elastic IPs created for AWS NAT Gateway |
| natgw_ids | List of NAT Gateway IDs |
| private_route_table_ids | List of IDs of private route tables |
| private_subnets | List of IDs of private subnets |
| private_subnets_az | List of the availability zones of private subnets |
| private_subnets_cidr_blocks | List of cidr_blocks of private subnets |
| public_route_table_ids | List of IDs of public route tables |
| public_subnets | List of IDs of public subnets |
| public_subnets_az | List of the availability zones of public subnets |
| public_subnets_cidr_blocks | List of cidr_blocks of public subnets |
| region | - |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_endpoint_s3_id | The ID of VPC endpoint for S3 |
| vpc_endpoint_s3_pl_id | The prefix list for the S3 VPC endpoint. |
| vpc_id | The ID of the VPC |
| vpc_name | - |


## Usage
**NOTE:** if you don't need a type of subnet, just leave if off. Below are all options available.
Just enter the number you need and they will be created with appropriately incremented /24
Cidr blocks, starting with the first /24 in your vpc cidr range above. For our uses please create 3
subnets per subnet type unless told otherwise. Even if you don't enter a /19, you will still wind up with
/24 subnets. If the CIDR block of the VPC is less than /24, i.e. /25, this module will not work.

## IMPORTANT ###
Modules have module outputs, but these outputs are more like resource attributes than actual outputs.
To make sure you can reference these outputs via terraform_remote_state, you MUST include your own
output file that outputs the module's outputs to the state file. This goes with your main.tf as output.tf
in the same ROOT folder where you called the module.
