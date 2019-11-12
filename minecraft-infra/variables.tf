variable "tfstate_global_bucket" {
  type = string
}

variable "tfstate_global_bucket_region" {
  type = string
}

variable "aws_region" {
	type = string
}

variable "tags" {
	type = map
}

variable "in_cidr_blocks" {
	type = list(string)
	description = "List of cidr blocks from which traffic is allowed in"
}

variable "public_key" {
	type = string
	description = "Public key to use in minecraft server instances"
}
