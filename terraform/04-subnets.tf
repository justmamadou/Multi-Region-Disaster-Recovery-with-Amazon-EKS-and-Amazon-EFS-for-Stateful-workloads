/************       Primary    *****************************/

resource "aws_subnet" "private_zone1-primary" {
  vpc_id = aws_vpc.primary.id
  cidr_block = "10.0.0.0/19"
  availability_zone = local.primary-az1
  provider = aws.eu-west-1

  tags = {
    "Name" = "${local.env1}-private-${local.primary-az1}"
    "kubernetes.io/role/internal-elb" ="1"
    "kubernetes.io/cluster/${local.env1}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone2-primary" {
  vpc_id = aws_vpc.primary.id
  cidr_block = "10.0.32.0/19"
  availability_zone = local.primary-az2
  provider = aws.eu-west-1

  tags = {
    "Name" = "${local.env1}-private-${local.primary-az2}"
    "kubernetes.io/role/internal-elb" ="1"
    "kubernetes.io/cluster/${local.env1}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone1-primary" {
  vpc_id = aws_vpc.primary.id
  cidr_block = "10.0.64.0/19"
  availability_zone = local.primary-az1
  map_public_ip_on_launch = true
  provider = aws.eu-west-1

  tags = {
    "Name"= "${local.env1}-public-${local.primary-az1}"
    "kubernetes.io/role/elb" ="1"
    "kubernetes.io/cluster/${local.env1}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone2-primary" {
  vpc_id = aws_vpc.primary.id
  cidr_block = "10.0.96.0/19"
  availability_zone = local.primary-az2
  map_public_ip_on_launch = true
  provider = aws.eu-west-1

  tags = {
    "Name"= "${local.env1}-public-${local.primary-az2}"
    "kubernetes.io/role/elb" ="1"
    "kubernetes.io/cluster/${local.env1}-${local.eks_name}" = "owned"
  }
}

/************       Backup    *****************************/

resource "aws_subnet" "private_zone1-backup" {
  vpc_id = aws_vpc.backup.id
  cidr_block = "10.0.0.0/19"
  availability_zone = local.backup-az1
  provider = aws.eu-west-2

  tags = {
    "Name" = "${local.env2}-private-${local.backup-az1}"
    "kubernetes.io/role/internal-elb" ="1"
    "kubernetes.io/cluster/${local.env2}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private_zone2-backup" {
  vpc_id = aws_vpc.backup.id
  cidr_block = "10.0.32.0/19"
  availability_zone = local.backup-az2
  provider = aws.eu-west-2

  tags = {
    "Name" = "${local.env2}-private-${local.backup-az2}"
    "kubernetes.io/role/internal-elb" ="1"
    "kubernetes.io/cluster/${local.env2}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone1-backup" {
  vpc_id = aws_vpc.backup.id
  cidr_block = "10.0.64.0/19"
  availability_zone = local.backup-az1
  map_public_ip_on_launch = true
  provider = aws.eu-west-2

  tags = {
    "Name"= "${local.env2}-public-${local.backup-az1}"
    "kubernetes.io/role/elb" ="1"
    "kubernetes.io/cluster/${local.env2}-${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public_zone2-backup" {
  vpc_id = aws_vpc.backup.id
  cidr_block = "10.0.96.0/19"
  availability_zone = local.backup-az2
  map_public_ip_on_launch = true
  provider = aws.eu-west-2

  tags = {
    "Name"= "${local.env2}-public-${local.backup-az2}"
    "kubernetes.io/role/elb" ="1"
    "kubernetes.io/cluster/${local.env2}-${local.eks_name}" = "owned"
  }
}