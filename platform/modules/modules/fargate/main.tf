provider "aws" {
  region  = var.provider_region
  profile = var.profile

  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/${var.role_name}"
  }
}

//TBD
locals {

  name            = format("bizwithai-fargate-eks-%s-%s", var.realm, var.region)
  cluster_version = var.cluster_version
  region          = var.provider_region
}



################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  subnets         = ["${data.terraform_remote_state.network.outputs.private_bizwithai_subnets[0]}", "${data.terraform_remote_state.network.outputs.public_bizwithai_subnets[1]}"]
  fargate_subnets = ["${data.terraform_remote_state.network.outputs.private_bizwithai_subnets[1]}"]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  node_groups = {
    example = {
      desired_capacity = 1

      instance_types = ["t3.large"]
      k8s_labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  manage_aws_auth = false

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Kubernetes provider configuration
################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
