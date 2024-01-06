terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}


provider "kubernetes" {
  

  host                   = data.aws_eks_cluster.myapp-cluster.endpoint
  token                  = data.aws_eks_cluster_auth.myapp-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_name
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"


  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.27"
  subnet_ids =  module.myapp-vpc.private_subnets 
  vpc_id = module.myapp-vpc.vpc_id


  tags = {
    name = "development"
    application = "myapp"
  }
  

  self_managed_node_group_defaults = {
    instance_type                          = "t2.medium"
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "mixed-1"
      max_size     = 2
      desired_size = 1
    }
}

}
