variable "tfstate_global_bucket" {
  type = string
}

variable "aws_region" {
	type = string
}

variable "environment" {
	type = string
	description = "Environment we are deploying into"
}

variable "name" {
	type = string
	description = "Name of the minecraft server"
}

variable "instance_type" {
	type = string
	description = "EC2 instance type to use for server"
	default = "t3.micro"
}

variable "memory" {
	type = string
	description = "Memory allocation to feed to java for server"
	default = "1024m"
}

variable "tags" {
	type = map(string)
}
