# Create a VPC
resource "aws_vpc" "group-project" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "group project"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.group-project.id

  tags = {
    Name = "IGW"
  }
}

# Create Public Subnets
resource "aws_subnet" "pub-sub1" {
  vpc_id     = aws_vpc.group-project.id
  cidr_block = var.pub-sub1-cidr

  tags = {
    Name = "pub sub1"
  }
}

resource "aws_subnet" "pub-sub2" {
  vpc_id     = aws_vpc.group-project.id
  cidr_block = var.pub-sub2-cidr

  tags = {
    Name = "pub sub2"
  }
}

# Create Private Subnets
resource "aws_subnet" "prvt-sub1" {
  vpc_id     = aws_vpc.group-project.id
  cidr_block = var.prvt-sub1-cidr

  tags = {
    Name = "prvt sub1"
  }
}


resource "aws_subnet" "prvt-sub2" {
  vpc_id     = aws_vpc.group-project.id
  cidr_block = var.prvt-sub2-cidr

  tags = {
    Name = "prvt sub2"
  }
}

# Create Route Table for Public Route
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.group-project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Create Route Table Assocition
# Associate Public Subnet 1 to "Public Route Table"
resource "aws_route_table_association" "pub-sub1-route_table_association" {
  subnet_id      = aws_subnet.pub-sub1.id
  route_table_id = aws_route_table.public-rt.id
}

# Associate Public Subnet 2 to "Public Route Table"
resource "aws_route_table_association" "pub-sub2-route_table_association" {
  subnet_id      = aws_subnet.pub-sub2.id
  route_table_id = aws_route_table.public-rt.id
}

# Allocate Elastic IP Address
resource "aws_eip" "EIP" {
  domain   = "vpc"
  
  tags = {
    Name = "EIP"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "natgtw" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.pub-sub1.id

  tags = {
    Name = "natgtw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

# Create Route Table for Private Route
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.group-project.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Create Route Table Assocition
# Associate Private Subnet 1 to "Private Route Table"
resource "aws_route_table_association" "prvt-sub1-route_table_association" {
  subnet_id      = aws_subnet.prvt-sub1.id
  route_table_id = aws_route_table.private-rt.id
}

# Associate Private Subnet 2 to "Private Route Table"
resource "aws_route_table_association" "prvt-sub2-route_table_association" {
  subnet_id      = aws_subnet.prvt-sub2.id
  route_table_id = aws_route_table.private-rt.id
}

# Create Security Group
resource "aws_security_group" "sec-group" {
  name        = "sec-group"
  description = "Allow SSH/HTTP access on port 80/22"
  vpc_id      = aws_vpc.group-project.id

  ingress {
    description      = "SSH/HTTP Access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group"
  }
}

# Create EC2 Instance
resource "aws_instance" "group-server" {
  ami               = "ami-020737107b4baaa50"
  instance_type     = "t2.micro"
  subnet_id         = aws_subnet.pub-sub1.id
  security_groups   = [aws_security_group.sec-group.id]
  availability_zone = "eu-west-2c"
  associate_public_ip_address = true
  user_data = file("entry-script.sh")

  tags = {
    Name = "Group Server"
  }
}