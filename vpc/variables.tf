variable "aws_region" {
	type = string
}

variable "vpc_cidr_block" {
	type = string
	default = "10.0.0.0/8"
}

variable "subnet_count" {
	type = number
	default = 3
}

variable "subnet_size" {
	type = number
	default = 8
	description = "Number of bits to add to the vpc cidr block mask"
}

variable "tags" {
	type = map
}
