provider "aws" {
    region = "eu-west-1"
    alias = "eu-west-1"
}

provider "aws" {
  region = "eu-west-2"
  alias = "eu-west-2"
}

terraform {
  required_version = ">=1.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.49"
    }
  }
}