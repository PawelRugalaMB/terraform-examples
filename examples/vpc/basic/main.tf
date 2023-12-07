provider "aws" {
    profile = "dev"
    region = "eu-central-1"
}

module "vpc" {
    source = "../../../modules/vpc"
    name = "my-vpc"
    cidr_block = "10.0.0.0/16"
    tags = {
        "Environment" = "dev"
        "Terraform" = true
    }
}