# vpc 
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# public subnet
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "${var.aws_region}${count.index == 0 ? "a" : "b"}" 

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }
}

# private subnet
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index + 2}.0/24"
  availability_zone = "${var.aws_region}${count.index == 0 ? "a" : "b"}" 

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name= "${var.project_name}-igw"
    } 
}

# Public Route table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "${var.project_name}-public-rt"
    }
}

# Associate rt with public subnet using count
resource "aws_route_table_association" "public" {
    count = 2
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
  
}


# Private Route table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "${var.project_name}-private-rt"
    }
}

# Associate rt with private subnet using count
resource "aws_route_table_association" "private" {
    count = 2
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
  
}