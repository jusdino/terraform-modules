resource aws_route_table private {
  count = var.internet ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[count.index].id
  }
}

resource aws_subnet private {
  count = var.subnet_count
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, var.subnet_size, count.index + var.subnet_count)
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
  tags = merge({Name = "${var.vpc_name}-subnet-${count.index}"}, var.tags)
}

resource aws_route_table_association private {
  count = var.subnet_count
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource aws_network_acl private {
  vpc_id = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id
  tags = merge({Name = var.vpc_name}, var.tags)
}

resource aws_network_acl_rule private_ssh_in {
  count = var.ssh ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_number = 229
  egress = false
  protocol = "tcp"
  cidr_block = aws_vpc.main.cidr_block
  rule_action = "allow"
  from_port = 22
  to_port = 22
}

resource aws_network_acl_rule private_http_out {
  count = var.http ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_number = 808
  egress = true
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 80
  to_port = 80
}

resource aws_network_acl_rule private_https_out {
  count = var.https ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_number = 4438
  egress = true
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 443
  to_port = 443
}

resource aws_network_acl_rule private_ephemeral_in {
  count = var.ephemeral ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_number = 10259
  egress = false
  protocol = "tcp"
  cidr_block = "0.0.0.0/0"
  rule_action = "allow"
  from_port = 1024
  to_port = 65535
}

resource aws_network_acl_rule private_ephemeral_out {
  count = var.ephemeral ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_number = 10258
  egress = true
  protocol = "tcp"
  cidr_block = aws_vpc.main.cidr_block
  rule_action = "allow"
  from_port = 1024
  to_port = 65535
}
