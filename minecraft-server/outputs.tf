output "server_ip" {
	value = aws_eip.server.public_ip
}

output "server_root_volume_size" {
	value = aws_instance.server.root_block_device[0].volume_size
}

output "server_fqdn" {
	value = aws_route53_record.server.fqdn
}