provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket  = "state-bucket-for-eks-deployment"
    key     = "./eks-app-deployment/"
    region  = "us-east-1"
    profile = "beach"
  }
  required_version = ">= 1.3.3"
}

