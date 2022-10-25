#terraform version and backend
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.region
  
}

# data "aws_availability_zones" "azs" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway  = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.5.0"
  count   = 1

  name = "web_server01"

  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  key_name               = "ubuntu_ec2"
  monitoring             = true
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = "${file("deploy.sh")}"


  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name = "Webserver001"
  }
}

# resource "aws_instance" "web_server01" {
#   ami = "ami-08c40ec9ead489470"
#   instance_type = "t2.micro"
#   key_name = "ubuntu_ec2"
#   vpc_security_group_ids = [aws_security_group.web_ssh.id]

#   user_data = "${file("deploy.sh")}"

#   tags = {
#     "Name" : "Webserver001"
#   }
  
# }

output "instance_ip" {
  # value = module.ec2_instances.public_ip[0]

  value = module.aws_instance.web_server01.public_ip
  
}
