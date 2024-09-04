provider "aws" {
  profile = "beach"
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.3.3"
}