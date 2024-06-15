# Configure provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "demo-server" {
    ami = "ami-033fabdd332044f06"
    instance_type = "t2.micro"
    key_name = "lsf-ovia-keys"
    security_groups = [ "ovia-sg" ]
}

# Configure Security Group
resource "aws_security_group" "ovia-sg" {
  name        = "ovia-sg"
  description = "SSH Access"

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