output "server_ip" {
	value = aws_instance.server.public_ip
}

output "server_fqdn" {
	value = aws_route53_record.server.fqdn
}