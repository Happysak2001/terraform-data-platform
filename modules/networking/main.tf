# ─────────────────────────────────────────
# VPC — Your private building on AWS
# Nothing gets in or out unless you allow it
# ─────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr        # IP range: 10.0.0.0/16 = 65,536 addresses
  enable_dns_hostnames = true                # lets EC2 get human-readable hostnames
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ─────────────────────────────────────────
# INTERNET GATEWAY — the front door of your building
# Without this, nothing inside can reach the internet
# ─────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id                   # attach it to our VPC

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ─────────────────────────────────────────
# PUBLIC SUBNET — the front desk / lobby
# Resources here CAN be reached from the internet
# EC2 (our processing server) lives here
# ─────────────────────────────────────────

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr   # 10.0.1.0/24 = 256 addresses
  availability_zone       = "${var.aws_region}a"     # e.g. us-east-1a
  map_public_ip_on_launch = true                     # EC2 gets a public IP automatically

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# ─────────────────────────────────────────
# PRIVATE SUBNET — the back office
# Resources here CANNOT be reached from the internet
# RDS (our database) lives here
# ─────────────────────────────────────────

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr        # 10.0.2.0/24 = 256 addresses
  availability_zone = "${var.aws_region}b"           # different AZ for resilience

  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# ─────────────────────────────────────────
# EXTRA PRIVATE SUBNET — RDS requires subnets in 2 different AZs
# Think of it as a backup room in a different floor
# ─────────────────────────────────────────

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr      # 10.0.3.0/24
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "${var.project_name}-private-subnet-2"
  }
}

# ─────────────────────────────────────────
# ROUTE TABLE — the road map inside your building
# Tells traffic: "to reach the internet, go through the Internet Gateway"
# ─────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                         # all internet traffic (0.0.0.0/0 = everywhere)
    gateway_id = aws_internet_gateway.main.id         # send it through the front door
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Connect the public subnet to the public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
