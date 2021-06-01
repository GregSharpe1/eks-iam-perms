data aws_eks_cluster cluster {
  name = module.cluster.cluster_id
}

data aws_eks_cluster_auth cluster {
  name = module.cluster.cluster_id
}

data aws_arn oidc-provider {
  arn = module.cluster.oidc_provider_arn
}

provider kubernetes {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module cluster {
  source          = "terraform-aws-modules/eks/aws?ref=13.0.0"

  cluster_name    = local.stack
  cluster_version = "1.16"

  subnets         = module.network.public_subnets
  vpc_id          = module.network.vpc_id

  write_kubeconfig = false
  enable_irsa = true

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 2
    }
  ]
}
