/********************** Primary ******************/
resource "aws_eip" "nat_ip_primary" {
  domain = "vpc"
  provider = aws.eu-west-1

  tags = {
    Name = "${local.env1}-nat"
  }
}

resource "aws_nat_gateway" "nat_primary" {
  allocation_id = aws_eip.nat_ip_primary.id
  subnet_id = aws_subnet.public_zone1-primary.id 
  provider = aws.eu-west-1
  tags = {
    Name = "${local.env1}-nat"
  }

  depends_on = [ aws_internet_gateway.igw-primary ]
}

/********************** Backup ******************/
resource "aws_eip" "nat_ip_backup" {
  domain = "vpc"
  provider = aws.eu-west-2
  tags = {
    Name = "${local.env2}-nat"
  }
}

resource "aws_nat_gateway" "nat-backup" {
  allocation_id = aws_eip.nat_ip_backup.id
  subnet_id = aws_subnet.public_zone1-backup.id 
  provider = aws.eu-west-2
  tags = {
    Name = "${local.env2}-nat"
  }

  depends_on = [ aws_internet_gateway.igw-backup ]
}