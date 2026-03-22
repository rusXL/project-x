# Route 53 private DNS + inbound Resolver endpoint

resource "aws_security_group" "resolver" {
  name        = "resolver-inbound-sg"
  description = "Allow DNS from GCP over VPN to Route 53 Resolver"
  vpc_id      = var.vpc_a_id

  ingress {
    description = "DNS UDP from GCP over VPN"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["35.199.192.0/19", var.gcp_subnet_cidr, var.aws_vpc_cidr]
  }

  ingress {
    description = "DNS TCP from GCP over VPN"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["35.199.192.0/19", var.gcp_subnet_cidr, var.aws_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "resolver-inbound-sg" }
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "resolver-inbound"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.resolver.id]

  ip_address {
    subnet_id = var.subnet_a_id
  }

  ip_address {
    subnet_id = var.subnet_b_id
  }

  tags = { Name = "resolver-inbound" }
}

resource "aws_route53_zone" "internal" {
  name = "project-x"

  vpc {
    vpc_id = var.vpc_a_id
  }

  tags = { Name = "project-x-private-zone" }
}

