provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

resource "aws_instance" "server" {
  ami = data.aws_ami.server.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = var.instance_type
  key_name = data.terraform_remote_state.minecraft_infra.outputs.public_key_name
  vpc_security_group_ids = [data.terraform_remote_state.minecraft_infra.outputs.security_group_id]
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_ids[0]
  associate_public_ip_address = true
  tags = merge({Name = var.name }, var.tags)
  volume_tags = merge({Name = var.name }, var.tags)
  user_data = <<USER_DATA
#!/bin/bash
export DATA_BUCKET=${data.terraform_remote_state.minecraft_infra.outputs.data_bucket_id}
export SERVER_NAME=${var.name}
env >/home/ec2-user/cloud-init.env
USER_DATA
}

data "aws_ami" "server" {
 most_recent = true
 owners = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.tfstate_global_bucket_region
    key = "dev/public/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "minecraft_infra" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.tfstate_global_bucket_region
    key = "dev/public/apps/minecraft-infra/terraform.tfstate"
  }
}
