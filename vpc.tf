provider "aws" {
  region = "us-east-2"
}

variable "private_subnets" {}
variable "public_subnets" {}
variable "cidr" {}
variable "env_prefix" {}



data "aws_availability_zones" "azs" {}



  module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  

  name = "myapp-vpc"
  cidr = var.cidr

  azs = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}
