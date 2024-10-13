/**************** Primary *****************/
resource "aws_route_table" "private-primary" {
  vpc_id = aws_vpc.primary.id
  provider = aws.eu-west-1

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_primary.id 
  }

  tags = {
    Name = "${local.env1}-private"
  }
}

resource "aws_route_table" "public-primary" {
  vpc_id = aws_vpc.primary.id
  provider = aws.eu-west-1

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-primary.id
  }

  tags= {
    Name = "${local.env1}-public"
  }
}

resource "aws_route_table_association" "private_zone1_primary" {
  subnet_id = aws_subnet.private_zone1-primary.id
  route_table_id = aws_route_table.private-primary.id
  provider = aws.eu-west-1
}

resource "aws_route_table_association" "private_zone2_primary" {
  subnet_id = aws_subnet.private_zone2-primary.id
  route_table_id = aws_route_table.private-primary.id
  provider = aws.eu-west-1
}

resource "aws_route_table_association" "public_zone1_primary" {
  subnet_id = aws_subnet.public_zone1-primary.id 
  route_table_id = aws_route_table.public-primary.id
  provider = aws.eu-west-1
}

resource "aws_route_table_association" "public_zone2_primary" {
  subnet_id = aws_subnet.public_zone2-primary.id
  route_table_id = aws_route_table.public-primary.id
  provider = aws.eu-west-1
}

/**************** Backup *****************/
resource "aws_route_table" "private-backup" {
  vpc_id = aws_vpc.backup.id
  provider = aws.eu-west-2

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-backup.id 
  }

  tags = {
    Name = "${local.env2}-private"
  }
}

resource "aws_route_table" "public-backup" {
  vpc_id = aws_vpc.backup.id
  provider = aws.eu-west-2

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-backup.id
  }

  tags= {
    Name = "${local.env2}-public"
  }
}

resource "aws_route_table_association" "private_zone1_backup" {
  subnet_id = aws_subnet.private_zone1-backup.id
  route_table_id = aws_route_table.private-backup.id
  provider = aws.eu-west-2
}

resource "aws_route_table_association" "private_zone2_backup" {
  subnet_id = aws_subnet.private_zone2-backup.id
  route_table_id = aws_route_table.private-backup.id
  provider = aws.eu-west-2
}

resource "aws_route_table_association" "public_zone1_backup" {
  subnet_id = aws_subnet.public_zone1-backup.id 
  route_table_id = aws_route_table.public-backup.id
  provider = aws.eu-west-2
}

resource "aws_route_table_association" "public_zone2_backup" {
  subnet_id = aws_subnet.public_zone2-backup.id
  route_table_id = aws_route_table.public-backup.id
  provider = aws.eu-west-2
}