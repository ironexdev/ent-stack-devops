terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-vpc"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-public-subnet-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-public-subnet-2"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = var.availability_zone1

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-private-subnet-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = var.availability_zone2

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-private-subnet-2"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-private-rt"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-ig"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.private.id
}
