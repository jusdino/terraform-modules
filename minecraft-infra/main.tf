locals {
	prod_non_prod = var.environment == "prod" ? "prod" : "non-prod"
	name = "minecraft-infra"
}

resource "aws_s3_bucket" "minecraft_data" {
	bucket = var.data_bucket_name
	acl = "private"
	force_destroy = true
	region = var.aws_region
}

resource "aws_security_group" "minecraft" {
	name = local.name
	vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

	ingress {
		description = "minecraft tcp"
		from_port = 25565
		to_port = 25565
		protocol = "tcp"
		cidr_blocks = var.in_cidr_blocks
	}

	ingress {
		description = "minecraft udp"
		from_port = 25565
		to_port = 25565
		protocol = "udp"
		cidr_blocks = var.in_cidr_blocks
	}

	ingress {
		description = "minecraft dynamap"
		from_port = 8123
		to_port = 8123
		protocol = "tcp"
		cidr_blocks = var.in_cidr_blocks
	}

	ingress {
		description = "ssh"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = var.in_cidr_blocks
	}

	egress {
		description = "all-out"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = merge({Name = "minecraft"}, var.tags)
}

resource "aws_key_pair" "minecraft" {
	key_name = "minecraft-${var.environment}"
	public_key = var.public_key
	tags = var.tags
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.aws_region
    key = "${local.prod_non_prod}/${var.aws_region}/_global/vpc/terraform.tfstate"
  }
}
