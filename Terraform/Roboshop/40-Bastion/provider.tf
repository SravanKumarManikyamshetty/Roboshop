terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.48.0"
    }
  }
  backend "s3" {
    bucket = "sravan-devops-project"
    key    = "Roboshop_bastion.tfstate"
    region = "us-east-1"
  }
}

  

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}