provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.tfstate_global_bucket_region
    key = "dev/public/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.tfstate_global_bucket_region
    key = "_global/dns/terraform.tfstate"
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
