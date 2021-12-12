# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = element(concat(aws_vpc.this.*.id, [""]), 0)
}

output "vpc_name" {
  value = "${var.name}-${var.realm}-${var.region}-main"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = element(concat(aws_vpc.this.*.cidr_block, [""]), 0)
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.this.default_security_group_id
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.this.default_network_acl_id
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.this.default_route_table_id

}

# Subnets
output "private_bizwithai_subnets" {
  description = "List of IDs of private bizwithai subnets"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_subnet.private_bizwithai.*.id) : "", )
}

output "private_bizwithai_subnets_az" {
  description = "List of the availability zones of private bizwithai subnets"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_subnet.private_bizwithai.*.availability_zone) : "", )
}

output "private_bizwithai_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private bizwithai subnets"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_subnet.private_bizwithai.*.cidr_block) : "", )
}

output "public_bizwithai_subnets" {
  description = "List of IDs of public bizwithai subnets"
  value       = split(",", var.public_bizwithai_subnets != "" ? join(",", aws_subnet.public_bizwithai.*.id) : "", )
}

output "public_bizwithai_subnets_az" {
  description = "List of the availability zones of public bizwithai subnets"
  value       = split(",", var.public_bizwithai_subnets != "" ? join(",", aws_subnet.public_bizwithai.*.availability_zone) : "", )
}

output "public_bizwithai_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public bizwithai subnets"
  value       = split(",", var.public_bizwithai_subnets != "" ? join(",", aws_subnet.public_bizwithai.*.cidr_block) : "", )
}

output "bizwithai_database_subnets" {
  description = "List of IDs of bizwithai database subnets"
  value       = split(",", var.bizwithai_database_subnets != "" ? join(",", aws_subnet.bizwithai_database.*.id) : "", )
}

output "bizwithai_database_subnets_az" {
  description = "List of the availability zones of bizwithai database subnets"
  value       = split(",", var.bizwithai_database_subnets != "" ? join(",", aws_subnet.bizwithai_database.*.availability_zone) : "", )
}

output "bizwithai_database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of bizwithai database subnets"
  value       = split(",", var.bizwithai_database_subnets != "" ? join(",", aws_subnet.bizwithai_database.*.cidr_block) : "", )
}

output "bizwithai_database_subnet_group" {
  description = "ID of bizwithai database subnet group"
  value       = element(concat(aws_db_subnet_group.bizwithai_database.*.id, [""]), 0)
}


# Route tables
output "public_bizwithai_route_table_ids" {
  description = "List of IDs of public bizwithai route tables"
  value       = split(",", var.public_bizwithai_subnets != "" ? join(",", aws_route_table.public_bizwithai.*.id) : "", )
}

output "private_bizwithai_route_table_ids" {
  description = "List of IDs of private bizwithai route tables"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_route_table.private_bizwithai.*.id) : "", )
}

output "private_bizwithai_database_route_table_ids" {
  description = "List of IDs of private bizwithai route tables for db"
  value       = split(",", var.bizwithai_database_subnets != "" ? join(",", aws_route_table.private_bizwithai_database.*.id) : "", )
}

output "nat_bizwithai_ids" {
  description = "List of allocation ID of Elastic IPs created for bizwithai AWS NAT Gateway"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_eip.nat_bizwithai.*.id) : "", )
}

output "nat_public_bizwithai_ips" {
  description = "List of public Elastic IPs created for bizwithai AWS NAT Gateway"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_eip.nat_bizwithai.*.public_ip) : "", )

}

output "natgw_bizwithai_ids" {
  description = "List of bizwithai NAT Gateway IDs"
  value       = split(",", var.private_bizwithai_subnets != "" ? join(",", aws_nat_gateway.this_bizwithai.*.id) : "", )
}

# Internet Gateway
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = element(concat(aws_internet_gateway.this.*.id, [""]), 0)

}
