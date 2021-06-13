resource aws_route53_zone main {
  name = var.dns_zone_name
  tags = merge({Name = var.dns_zone_name }, var.tags)
}

resource aws_route53_record no_email {
  zone_id = aws_route53_zone.main.id
  name = var.dns_zone_name
  type = "TXT"
  ttl = "60"
  records = ["v=spf1 -all"]
}