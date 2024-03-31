resource "aws_vpc" "Stack-VPC" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "Stack-vpc"
  }
}

resource "aws_subnet" "Stack-private-subnet-1" {
  vpc_id     = aws_vpc.Stack-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
   tags = {
    Name = "Stack-private-subnet-1"
  }
}

resource "aws_subnet" "Stack-private-subnet-2" {
  vpc_id     = aws_vpc.Stack-VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Stack-private-subnet-2"
  }
}

resource "aws_subnet" "Stack-public-subnet-1" {
  vpc_id     = aws_vpc.Stack-VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Stack-public-subnet-1"
  }
}

resource "aws_subnet" "Stack-public-subnet-2" {
  vpc_id     = aws_vpc.Stack-VPC.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Stack-public-subnet-2"
  }
}

##### CREATE INTERNET GATEWAY ###########

resource "aws_internet_gateway" "Stack-igw" {
  vpc_id = aws_vpc.Stack-VPC.id
  tags = {
    Name = "Stack-vpc-IGW"
    }
}

####### CREATE ROUTE TABLES ###########

resource "aws_route_table" "Stack-public-route-table" {
  vpc_id = aws_vpc.Stack-VPC.id
  tags = {
    Name = "Stack-public-route-table"
  }
}

resource "aws_route" "Stack-public-route" {
  route_table_id         = aws_route_table.Stack-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Stack-igw.id
}

resource "aws_route_table_association" "Stack-public-subnet-1-association" {
  subnet_id      = aws_subnet.Stack-public-subnet-1.id
  route_table_id = aws_route_table.Stack-public-route-table.id
}

resource "aws_route_table_association" "Stack-public-subnet-2-association" {
  subnet_id      = aws_subnet.Stack-public-subnet-2.id
  route_table_id = aws_route_table.Stack-public-route-table.id
}

resource "aws_route_table" "Stack-private-route-table" {
  vpc_id = aws_vpc.Stack-VPC.id
    route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Stack-nat-gateway.id
  }

   tags = {
    Name = "Stack-private-route-table"
  }
}



### ROUTE TABLE FOR PRIVATE SUBNETS #######
resource "aws_route_table_association" "Stack-private-subnet-1-association" {
  subnet_id      = aws_subnet.Stack-private-subnet-1.id
  route_table_id = aws_route_table.Stack-private-route-table.id
}

resource "aws_route_table_association" "Stack-private-subnet-2-association" {
  subnet_id      = aws_subnet.Stack-private-subnet-2.id
  route_table_id = aws_route_table.Stack-private-route-table.id
}

##### CREATE NAT Gateway ############

resource "aws_eip" "Stack-nat-eip" {
     tags = {
      Name = "Stack-nat-eip"
      }
}

resource "aws_nat_gateway" "Stack-nat-gateway" {
  allocation_id = aws_eip.Stack-nat-eip.id
  subnet_id     = aws_subnet.Stack-public-subnet-1.id  # Reference the first public subnet
  tags = {
      Name = "Stack-nat-gateway"
      }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.Stack-private-subnet-1.id
  route_table_id = aws_route_table.Stack-private-route-table.id
}

resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
 subnet_ids = [
    aws_subnet.Stack-private-subnet-1.id,
    aws_subnet.Stack-private-subnet-2.id
  ]
}







 

