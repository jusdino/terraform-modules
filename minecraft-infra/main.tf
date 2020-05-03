provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "minecraft_data" {
	bucket = var.data_bucket_name
	acl = "private"
	force_destroy = true
	region = var.aws_region
}

resource "aws_security_group" "minecraft" {
	name = "minecraft"
	vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

	ingress {
		from_port = 25565
		to_port = 25565
		protocol = "tcp"
		cidr_blocks = var.in_cidr_blocks
	}

	ingress {
		from_port = 25565
		to_port = 25565
		protocol = "udp"
		cidr_blocks = var.in_cidr_blocks
	}

	ingress {
		from_port = 8123
		to_port = 8123
		protocol = "tcp"
		cidr_blocks = var.in_cidr_blocks
	}

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = var.in_cidr_blocks
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = merge({Name = "minecraft"}, var.tags)
}

resource "aws_key_pair" "minecraft" {
	key_name = "minecraft"
	public_key = var.public_key
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.tfstate_global_bucket_region
    key = "us-west-1/dev/public/vpc/terraform.tfstate"
  }
}
