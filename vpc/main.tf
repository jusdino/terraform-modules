resource aws_vpc main {
	cidr_block = var.vpc_cidr_block
	tags = merge({Name = var.vpc_name}, var.tags)
}

resource aws_internet_gateway main {
	count = var.internet ? 1 : 0
	vpc_id = aws_vpc.main.id
	tags = merge({Name = var.vpc_name}, var.tags)
}

data aws_availability_zones available {
	state = "available"
}

