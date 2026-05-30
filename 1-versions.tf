# Terraform Settings Block
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">= 4.65"
      version = ">= 5.31"
     }
  }
  backend "s3" {
    bucket = "terraform-demo-for-eks1"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}


# Terraform Provider Block
provider "aws" {
  region = var.aws_region
}
