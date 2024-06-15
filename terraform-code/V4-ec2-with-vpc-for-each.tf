# Configure provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "ovia-server" {
    ami = "ami-09040d770ffe2224f"
    instance_type = "t2.micro"
    key_name = "lsf-ovia-keys"
    # security_groups = [ "ovia-sg" ]
    vpc_security_group_ids = [ aws_security_group.ovia-sg.id ]
    subnet_id = aws_subnet.ovia-public_subnet1.id
    for_each = toset(["jenkins-master", "jenkins-build-node", "ansible-server"])
   tags = {
     Name = "${each.key}"
   }
}

# Configure Security Group
resource "aws_security_group" "ovia-sg" {
  name        = "ovia-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.ovia-vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-access"
  }
}

#Create a VPC
resource "aws_vpc" "ovia-vpc" {
       cidr_block = "10.0.0.0/16"
       tags = {
        Name = "ovia-vpc"
     }
   }

   # Create Subnet1
   resource "aws_subnet" "ovia-public_subnet1" {
    vpc_id = aws_vpc.ovia-vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2a"
    tags = {
      Name = "ovia-public_subnet1"
    }
}

# Create Subnet2
   resource "aws_subnet" "ovia-public_subnet2" {
    vpc_id = aws_vpc.ovia-vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-2a"
    tags = {
      Name = "ovia-public_subnet2"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ovia-igw" {
    vpc_id = aws_vpc.ovia-vpc.id
    tags = {
      Name = "ovia-igw"
    }
}

# Create Route Table
resource "aws_route_table" "ovia-public-rt" {
    vpc_id = aws_vpc.ovia-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ovia-igw.id
    }
    tags = {
      Name = "ovia-public-rt"
    }
}

# Associate Subnet1 with Route Table
resource "aws_route_table_association" "ovia-rta-public-subent1" {
    subnet_id = aws_subnet.ovia-public_subnet1.id
    route_table_id = aws_route_table.ovia-public-rt.id
}

# Associate Subnet2 with Route Table
resource "aws_route_table_association" "ovia-rta-public-subnet2" {
    subnet_id = aws_subnet.ovia-public_subnet2.id
    route_table_id = aws_route_table.ovia-public-rt.id
}