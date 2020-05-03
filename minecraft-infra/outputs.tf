output "security_group_id" {
	value = aws_security_group.minecraft.id
}

output "public_key_name" {
	value = aws_key_pair.minecraft.key_name
}

output "data_bucket_id" {
	value = aws_s3_bucket.minecraft_data.id
}

output "data_bucket_arn" {
	value = aws_s3_bucket.minecraft_data.arn
}
