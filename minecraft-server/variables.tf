variable "tfstate_global_bucket" {
  type = string
}

variable "tfstate_global_bucket_region" {
  type = string
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

variable "tags" {
	type = map
}
