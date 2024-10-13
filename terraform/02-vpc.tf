resource "aws_vpc" "primary" {
    cidr_block = "10.0.0.0/16"

    enable_dns_hostnames = true
    enable_dns_support = true

    provider = aws.eu-west-1

    tags = {
      Name = "${local.env1}-main"
    }
  
}

resource "aws_vpc" "backup" {
    cidr_block = "10.0.0.0/16"
    
    provider = aws.eu-west-2

    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "${local.env2}-main"
    }
  
}