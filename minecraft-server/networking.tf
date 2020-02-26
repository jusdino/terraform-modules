resource "aws_eip" "server" {
  instance = aws_instance.server.id
  vpc = true
  tags = merge({Name = var.name }, var.tags)
}

resource "aws_route53_record" "server" {
  zone_id = data.terraform_remote_state.dns.outputs.hosted_zone_id
  name = var.name
  type = "A"
  ttl = 60
  records = [aws_eip.server.public_ip]
}