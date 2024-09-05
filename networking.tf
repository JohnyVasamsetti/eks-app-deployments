resource "aws_vpc" "main_vpc" {
  cidr_block = local.main_vpc_cidr_block
  tags = {
    task = "eks-app-deployment"
    Name = "main-vpc"
  }
}

# Gateways
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    task = "eks-app-deployment"
    Name = "main-igw"
  }
}
resource "aws_eip" "public_eip" {
  domain = "vpc"
  tags = {
    task = "eks-app-deployment"
    Name = "public-eip"
  }
}
resource "aws_nat_gateway" "main_ngw" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.public_eip.id
  tags = {
    task = "eks-app-deployment"
    Name = "main-ngw"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.public_subnet_cidr_block_1
  availability_zone       = local.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    task                                          = "eks-app-deployment"
    Name                                          = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.public_subnet_cidr_block_2
  availability_zone       = local.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    task                                          = "eks-app-deployment"
    Name                                          = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = local.private_subnet_cidr_block_1
  availability_zone = local.availability_zone_1
  tags = {
    task                                          = "eks-app-deployment"
    Name                                          = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = local.private_subnet_cidr_block_2
  availability_zone = local.availability_zone_2
  tags = {
    task                                          = "eks-app-deployment"
    Name                                          = "private-subnet-2"
  }
}

# Route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    task = "eks-app-deployment"
    Name = "public-route-table"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_ngw.id
  }
  tags = {
    task = "eks-app-deployment"
    Name = "private-route-table"
  }
}

# Attaching route tables with subnets
resource "aws_route_table_association" "public_rt_1_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
resource "aws_route_table_association" "public_rt_2_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}
resource "aws_route_table_association" "private_rt_1_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1.id
}
resource "aws_route_table_association" "private_rt_2_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_2.id
}
