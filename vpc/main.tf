terraform {
  backend "s3" {}
}

resource "aws_vpc" "main" {
	cidr_block = var.vpc_cidr_block
	tags = merge({Name = "main-vpc"}, var.tags)
}

resource "aws_subnet" "main" {
	count = var.subnet_count
	vpc_id = aws_vpc.main.id
	cidr_block = cidrsubnet(var.vpc_cidr_block, var.subnets_size, var.subnet_count)
	availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
	tags = merge({Name = "Subnet-${count.index)}, var.tags)
}

data "aws_availability_zones" "available" {
	state = "available"
}
