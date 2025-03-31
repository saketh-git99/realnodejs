terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "nodejs-bucket-27032025"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"
}
