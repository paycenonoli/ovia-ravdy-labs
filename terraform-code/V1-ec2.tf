# Configure provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "demo-server" {
    ami = "ami-033fabdd332044f06"
    instance_type = "t2.micro"
    key_name = "lsf-ovia-keys"
}