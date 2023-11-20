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



resource "aws_instance" "terraformInstance" {

  ami           = "ami-05c13eab67c5d8861"
  instance_type = "t2.micro"
  tags = {
    Name = "terraformGettingStarted"
  }
  count = 2
  vpc_security_group_ids = [ aws_security_group.terraformSG.id ]

}
resource "aws_security_group" "terraformSG" {

  name =   "terraformSG" 
  description = "Allow HTTP and SSH inbound traffic"
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80  
    protocol    = "tcp"
  }

  

}

