module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = var.aws_vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform                                   = "true"
    Environment                                 = "producao"
    Projeto                                     = "live"
    "kubernetes.io/cluster/${var.aws_eks_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.aws_eks_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.aws_eks_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.aws_eks_name
  kubernetes_version = "1.32" # DICA: Evite versoes nao lancadas como 1.36; use versoes estáveis suportadas pela AWS (ex: 1.31 ou 1.32)

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      # MUDANÇA CRÍTICA: t3.medium suporta até 17 pods e aloca interfaces de rede necessárias
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 2
      desired_size = 2

      # Garante associacao de rede adequada nas subnets privadas
      subnet_ids = module.vpc.private_subnets

      tags = {
        Terraform   = "true"
        Environment = "producao"
        Projeto     = "live"
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "producao"
    Projeto     = "live"
  }
}