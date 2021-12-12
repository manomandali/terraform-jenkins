######
# VPC
######
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("%s-%s-%s-main", var.name, var.realm, var.region)
    },
  )

}


###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count  = (var.public_bizwithai_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("bizwithai-igw-%s-%s-net-${count.index}", var.realm, var.region)
    },
  )

}

##########################
# AWS Default Route Table
##########################
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("bizwithai-%s-%s-%s-default", var.name, var.realm, var.region)
    },
  )

}

################
# Publiс routes
################
resource "aws_route_table" "public_bizwithai" {
  count  = var.public_bizwithai_subnets
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    var.public_route_table_tags,
    {
      "Name" = format(
        "bizwithai-%s-%s-%s-public-${count.index}",
        var.name,
        var.realm,
        var.region,
      )
    },
  )
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.public_bizwithai_subnets
  route_table_id         = element(aws_route_table.public_bizwithai.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

}

#################
# Private routes
#################
resource "aws_route_table" "private_bizwithai" {
  count  = var.private_bizwithai_subnets
  vpc_id = aws_vpc.this.id
  # propagating_vgws = var.private_propagating_vgws
  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      "Name" = format(
        "bizwithai-%s-%s-%s-private-${count.index}",
        var.name,
        var.realm,
        var.region,
      )
    },
  )

  lifecycle {
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    # ignore_changes = [propagating_vgws]
  }
}

resource "aws_route_table" "private_bizwithai_database" {
  count  = var.bizwithai_database_subnets
  vpc_id = aws_vpc.this.id
  # propagating_vgws = var.private_propagating_vgws
  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      "Name" = format(
        "bizwithai-db-%s-%s-%s-private-${count.index}",
        var.name,
        var.realm,
        var.region,
      )
    },
  )

  lifecycle {
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    # ignore_changes = [propagating_vgws]
  }
}

################
# SUBNETS
################

################
# Public subnet
################
resource "aws_subnet" "public_bizwithai" {
  count                   = var.public_bizwithai_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr, 24 - substr(var.cidr, -2, 2), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = merge(
    var.tags,
    var.public_subnet_tags,
    {
      "Name" = format(
        "bizwithai-%s-%s-%s-public-${count.index}",
        var.name,
        var.realm,
        var.region,
      )
    },
    {
      format("kubernetes.io/cluster/bizwithai-fargate-eks-%s-%s", var.realm, var.region) = "shared"
    },
    {
      format("kubernetes.io/role/elb/bizwithai-fargate-eks-%s-%s", var.realm, var.region) = "1"
    },
  )
}


#################
# Private subnet
#################

resource "aws_subnet" "private_bizwithai" {
  count             = var.private_bizwithai_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, 24 - substr(var.cidr, -2, 2), count.index + 4)
  availability_zone = element(var.azs, count.index)
  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      "Name" = format(
        "bizwithai-services-%s-%s-%s-private-${count.index}",
        var.name,
        var.realm,
        var.region,
      )
    },
    {
      format("kubernetes.io/cluster/bizwithai-fargate-eks-%s-%s", var.realm, var.region) = "shared"
    },
    {
      format("kubernetes.io/role/internal-elb/bizwithai-fargate-eks-%s-%s", var.realm, var.region) = "1"
    },
  )
}

##################
# Database subnet
##################
resource "aws_subnet" "bizwithai_database" {
  count             = var.bizwithai_database_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, 24 - substr(var.cidr, -2, 2), count.index + 8)
  availability_zone = element(var.azs, count.index)
  tags = merge(
    var.tags,
    var.database_subnet_tags,
    {
      "Name" = format(
        "bizwithai-db-%s-%s-%s-${count.index}",
        var.name,
        var.realm,
        var.region,
      )
    },
  )
}

resource "aws_db_subnet_group" "bizwithai_database" {
  count       = var.bizwithai_database_subnets > 0 && var.create_bizwithai_database_subnet_group ? 1 : 0
  name        = "bizwithai-bizwithai-grp-${var.name}-${var.realm}-${var.region}"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.bizwithai_database.*.id
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

##############
# NAT Gateway
##############

locals {
  nat_gateway_bizwithai_ips = split(
    ",",
    var.reuse_nat_bizwithai_ips ? join(",", var.external_nat_ip_bizwithai_ids) : join(",", aws_eip.nat_bizwithai.*.id),
  )
}

resource "aws_eip" "nat_bizwithai" {
  count = var.enable_bizwithai_nat_gateway && false == var.reuse_nat_bizwithai_ips ? (var.private_bizwithai_subnets) : 0
  vpc   = true
  tags = merge(
    var.tags,
    {
      "Name" = format("bizwithai-eip-%s-%s-net-${count.index}", var.realm, var.region)
    },
  )
}


resource "aws_nat_gateway" "this_bizwithai" {
  count         = var.enable_bizwithai_nat_gateway ? var.private_bizwithai_subnets : 0
  allocation_id = element(local.nat_gateway_bizwithai_ips, count.index)
  subnet_id     = element(aws_subnet.public_bizwithai.*.id, count.index)
  tags = merge(
    var.tags,
    {
      "Name" = format("bizwithai-nat-%s-%s-net-${count.index}", var.realm, var.region)
    },
  )
  depends_on = [aws_internet_gateway.this]
}


#########################
# DEFAULT Security Group
#########################
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("bizwithai-sg-%s-%s-%s-default", var.name, var.realm, var.region)
    },
  )

}


##########################
# Route table association
##########################
resource "aws_route_table_association" "private_bizwithai" {
  count          = var.private_bizwithai_subnets
  subnet_id      = element(aws_subnet.private_bizwithai.*.id, count.index)
  route_table_id = element(aws_route_table.private_bizwithai.*.id, count.index)
}


resource "aws_route_table_association" "bizwithai_database" {
  count          = var.bizwithai_database_subnets
  subnet_id      = element(aws_subnet.bizwithai_database.*.id, count.index)
  route_table_id = element(aws_route_table.private_bizwithai_database.*.id, count.index)
}

resource "aws_route_table_association" "public_bizwithai" {
  count          = var.public_bizwithai_subnets
  subnet_id      = element(aws_subnet.public_bizwithai.*.id, count.index)
  route_table_id = element(aws_route_table.public_bizwithai.*.id, count.index)
}


######################
# Public Subnet NACL's
######################

resource "aws_network_acl" "egress_bizwithai" {
  count      = var.public_bizwithai_subnets
  vpc_id     = aws_vpc.this.id
  subnet_ids = [element(aws_subnet.public_bizwithai.*.id, count.index)]
  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("%s-%s-%s-nacl", var.name, var.realm, var.region)
    },
  )

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.cidr
    from_port  = 22
    to_port    = 23
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 135
    to_port    = 135
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 137
    to_port    = 139
  }

  egress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 161
    to_port    = 162
  }

  egress {
    rule_no    = 140
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  egress {
    rule_no    = 150
    protocol   = "tcp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 6660
    to_port    = 6669
  }

  egress {
    rule_no    = 160
    protocol   = "udp"
    action     = "allow"
    cidr_block = "10.5.128.0/20"
    from_port  = 22
    to_port    = 23
  }

  egress {
    rule_no    = 170
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 69
    to_port    = 69
  }

  egress {
    rule_no    = 180
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 135
    to_port    = 135
  }

  egress {
    rule_no    = 190
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 137
    to_port    = 139
  }

  egress {
    rule_no    = 200
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 161
    to_port    = 162
  }

  egress {
    rule_no    = 210
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 445
    to_port    = 445
  }

  egress {
    rule_no    = 220
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 514
    to_port    = 514
  }

  egress {
    rule_no    = 230
    protocol   = "udp"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  egress {
    rule_no    = 240
    protocol   = "all"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    protocol   = "all"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
