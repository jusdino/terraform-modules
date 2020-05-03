locals {
  prod_non_prod = var.environment == "prod" ? "prod" : "non-prod"
  name = "minecraft-infra"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.aws_region
    key = "${local.prod_non_prod}/${var.aws_region}/_global/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.aws_region
    key = "${local.prod_non_prod}/${var.aws_region}/_global/dns/terraform.tfstate"
  }
}

data "terraform_remote_state" "minecraft_infra" {
  backend = "s3"
  config = {
    bucket = var.tfstate_global_bucket
    region = var.aws_region
    key = "${local.prod_non_prod}/${var.aws_region}/${var.environment}/apps/minecraft-infra/terraform.tfstate"
  }
}
