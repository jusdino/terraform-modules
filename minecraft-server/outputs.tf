output "server_ip" {
	value = aws_eip.server.public_ip
}

output "server_fqdn" {
	value = aws_route53_record.server.fqdn
}