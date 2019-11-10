provider "aws" {
	region = var.aws_region
}

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
	cidr_block = cidrsubnet(var.vpc_cidr_block, var.subnet_size, count.index)
	availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
	tags = merge({Name = "Subnet-${count.index}"}, var.tags)
}

data "aws_availability_zones" "available" {
	state = "available"
}
provider "aws" {
	region = var.aws_region
}

terraform {
  backend "s3" {}
}

resource "aws_network_acl" "main" {
	vpc_id = aws_vpc.id
	tags = merge({Name = "main-vpc-nacl"}, var.tags)
}

resource "aws_network_acl_rule" "ssh_in" {
	count = var.ssh ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 229
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	from_port = 22
	to_port = 22
}

resource "aws_network_acl_rule" "ssh_out" {
	count = var.ssh ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 228
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	from_port = 22
	to_port = 22
}

resource "aws_network_acl_rule" "http_in" {
	count = var.http ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 809
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	from_port = 80
	to_port = 80
}

resource "aws_network_acl_rule" "http_out" {
	count = var.http ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 808
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	from_port = 80
	to_port = 80
}

resource "aws_network_acl_rule" "https_in" {
	count = var.https ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 4439
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	from_port = 443
	to_port = 443
}

resource "aws_network_acl_rule" "https_out" {
	count = var.https ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 4438
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	from_port = 443
	to_port = 443
}

resource "aws_network_acl_rule" "minecraft_in" {
	count = var.minecraft ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 20000
	egress = false
	protocol = -1
	rule_action = "allow"
	from_port = 25565
	to_port = 25565
}

resource "aws_network_acl_rule" "ephemeral_out" {
	count = var.https ? 1 : 0
	network_acl_id = aws_network_acl.id
	rule_number = 10258
	egress = true
	protocol = -1
	rule_action = "allow"
	from_port = 1025
	to_port = 65535
}

