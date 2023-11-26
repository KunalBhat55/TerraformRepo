terraform { // terraform block defines the version of terraform to be used and the backend configuration

  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws" //  location of the provider plugin.
      version = "~> 5.0"        //  Terraform registry path
    }

  }
}
# configure the AWS provider
provider "aws" {

  region = "us-east-1"

}

# EC2 instance
resource "aws_instance" "terraformInstance" {

  ami           = "ami-05c13eab67c5d8861"
  instance_type = "t2.micro"
  tags = {
    Name = "terraformGettingStarted"
  }
  vpc_security_group_ids = [aws_security_group.terraformSG.id]
  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   private_key = file("C:/Users/kunal/Desktop/terraform.pem")
  #   host        = self.public_ip
  # }

}
resource "aws_s3_bucket" "Bucket" {
  
  bucket = "terraform-bucket-123456789"
  
}
resource "aws_s3_bucket_lifecycle_configuration" "BucketLifecycle" {
  
  bucket = aws_s3_bucket.Bucket.id
  rule {
    status = "Enabled"
    id = "Rule-1"
    expiration {
      days = 80
    }
  }
   
  
}

# VPC
resource "aws_vpc" "VPC" {
  cidr_block = "192.168.0.0/16"
}

# Security Group
resource "aws_security_group" "terraformSG" {

  name        = "terraformSG"
  description = "Allow HTTP and SSH inbound traffic"
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  vpc_id = aws_vpc.VPC.id
  lifecycle {
    create_before_destroy = true
  }
}

# IGW
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
}

# Subnet
resource "aws_subnet" "SUBNET" {
 
 vpc_id = aws_vpc.VPC.id  
 map_public_ip_on_launch = true
  
}

# EBS
resource "aws_ebs_volume" "terraformEBS" {

  availability_zone = "us-east-1a"
  size              = 2
  tags = {
    name        = "terraformEBS"
    description = "EBS volume created from terraform"
  }
  
  
}

// Data sources allow Terraform to use information defined outside of Terraform.
data "aws_ami" "MyAmiId" {

  most_recent = true
  owners      = ["amazon"]

}
// Output block defines values that are highlighted to the user when Terraform applies the configuration.
output "AMI_ID" {

  value       = data.aws_ami.MyAmiId.id
  description = "value of the AMI id"

}
output "EBS_ID" {

  value       = aws_ebs_volume.terraformEBS.id
  description = "value of the EBS id"

}