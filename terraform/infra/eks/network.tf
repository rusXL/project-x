# networks
resource "aws_vpc" "vpc_a" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "vpc-a" }
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.aws_subnet_cidr
  availability_zone       = var.aws_zone
  map_public_ip_on_launch = true
  tags = {
    Name                              = "subnet-a"
    "kubernetes.io/cluster/cluster-a" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.aws_subnet_b_cidr
  availability_zone       = var.aws_zone_b
  map_public_ip_on_launch = true
  tags = {
    Name                              = "subnet-b"
    "kubernetes.io/cluster/cluster-a" = "owned"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "igw-a" }
}

resource "aws_route_table" "rt_a" {
  vpc_id = aws_vpc.vpc_a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }
  tags = { Name = "rt-a" }
}

resource "aws_route_table_association" "rta_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt_a.id
}

resource "aws_route_table_association" "rta_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt_a.id
}
