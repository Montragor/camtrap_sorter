terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

backend "s3" {
    bucket       = "camtrap-sorter-tfstate-636058550437-eu-central-1-an"
    key          = "terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}
provider "aws" {
  region  = "eu-central-1"
  profile = var.aws_profile
}