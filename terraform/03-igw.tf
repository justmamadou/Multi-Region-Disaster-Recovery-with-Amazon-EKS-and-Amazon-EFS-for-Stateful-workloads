resource "aws_internet_gateway" "igw-primary" {
  vpc_id = aws_vpc.primary.id

  provider = aws.eu-west-1

  tags = {
    Name = "${local.env1}-igw"
  }
}

resource "aws_internet_gateway" "igw-backup" {
  vpc_id = aws_vpc.backup.id

  provider = aws.eu-west-2

  tags = {
    Name = "${local.env2}-igw"
  }
}