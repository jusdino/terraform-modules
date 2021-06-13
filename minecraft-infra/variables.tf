variable tfstate_global_bucket {
  type = string
}

variable aws_region {
	type = string
}

variable environment {
	type = string
	description = "Environment we are deploying into"
}

variable tags {
	type = map(string)
}

variable in_cidr_blocks {
	type = list(string)
	description = "List of cidr blocks from which traffic is allowed in"
}

variable public_key {
	type = string
	description = "Public key to use in minecraft server instances"
}

variable data_bucket_name {
	type = string
	description = "Name of s3 bucket used to house server data"
}
