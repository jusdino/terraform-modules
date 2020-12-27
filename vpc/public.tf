resource aws_route_table public {
  count = var.internet ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }
}

resource aws_eip nat {
  count = var.subnet_count
  vpc = true
}

resource aws_nat_gateway public {
  count = var.subnet_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id
}

resource aws_subnet public {
  count = var.subnet_count
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, var.subnet_size, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
  tags = merge({Name = "${var.vpc_name}-subnet-${count.index}"}, var.tags)
}

resource aws_route_table_association public {
  count = var.internet ? var.subnet_count : 0
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource aws_network_acl public {
  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id
  tags = merge({Name = var.vpc_name}, var.tags)
}

resource aws_network_acl_rule public_ssh_in {
  count = var.ssh ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 229
  egress = false
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 22
  to_port = 22
}

resource aws_network_acl_rule public_ssh_out {
  count = var.ssh ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 228
  egress = true
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 22
  to_port = 22
}

resource aws_network_acl_rule public_http_in {
  count = var.http ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 809
  egress = false
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 80
  to_port = 80
}

resource aws_network_acl_rule public_http_out {
  count = var.http ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 808
  egress = true
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 80
  to_port = 80
}

resource aws_network_acl_rule public_https_in {
  count = var.https ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 4439
  egress = false
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 443
  to_port = 443
}

resource aws_network_acl_rule public_https_out {
  count = var.https ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 4438
  egress = true
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 443
  to_port = 443
}

resource aws_network_acl_rule public_minecraft_in {
  count = var.minecraft ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 20000
  egress = false
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 25565
  to_port = 25565
}

resource aws_network_acl_rule public_ephemeral_in {
  count = var.ephemeral ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 10259
  egress = false
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 1025
  to_port = 65535
}

resource aws_network_acl_rule public_ephemeral_out {
  count = var.ephemeral ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_number = 10258
  egress = true
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 1025
  to_port = 65535
}
