resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc-cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy = "default"
  tags = {
    Name = "Vpc-resume-app"
    env  = "dev"
    Team = "devops"
    
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "IGW"
  }
}

# Public Subnets
resource "aws_subnet" "sub1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-1a"
  }
}

resource "aws_subnet" "sub2" { 
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-1b"
  }
}

# Private Subnets
resource "aws_subnet" "sub3" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-1a"
  }
}

resource "aws_subnet" "sub4" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-1b"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "eip" {
  domain = "vpc" # Added domain requirement for modern AWS provider versions
}

# NAT Gateway
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.sub1.id

  tags = {
    Name = "gw NAT"
  }
}

# ==================== PUBLIC ROUTING ====================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_association1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.sub2.id # This now successfully targets the fixed subnet reference above
  route_table_id = aws_route_table.public.id
}

# ==================== PRIVATE ROUTING ====================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "internet_access1" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat1.id # Fixed: changed gateway_id to nat_gateway_id
}

resource "aws_route_table_association" "private_association1" {
  subnet_id      = aws_subnet.sub3.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_association2" {
  subnet_id      = aws_subnet.sub4.id
  route_table_id = aws_route_table.private.id
}


# create a subdomaine in route 53


resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.id
  name    = "terraform.dnc.beauty"
  type    = "A"
  ttl     = 300
  records = ["200.10.19.34"]
}
