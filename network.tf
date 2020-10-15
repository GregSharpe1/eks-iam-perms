data "aws_availability_zones" "available" {}

module network {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.25.0"
  name = local.stack
  cidr = local.cidr_range

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]

  private_subnets = [
    for subnet in var.private_subnet_numbers :
    cidrsubnet(local.cidr_range, 8, subnet)
  ]

  public_subnets = [
    for subnet in var.public_subnet_numbers :
    cidrsubnet(local.cidr_range, 8, subnet)
  ]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = map(
    "kubernetes.io/cluster/${local.stack}", "shared",
    "kubernetes.io/role/elb", "1"
  )

  # EKS tags
  tags = "${merge(
    map(
      "kubernetes.io/cluster/${local.stack}", "shared"
  ))}"
}

