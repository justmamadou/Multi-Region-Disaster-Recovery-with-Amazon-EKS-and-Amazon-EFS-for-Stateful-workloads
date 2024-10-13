locals {
  env1 = "primary"
  env2  = "backup"
  primary-region = "eu-west-1"
  backup-region = "eu-west-2"
  primary-az1= "eu-west-1a"
  primary-az2 = "eu-west-1b"
  backup-az1= "eu-west-2a"
  backup-az2 = "eu-west-2b"
  eks_name = "demo"
  eks_version = "1.30"
}