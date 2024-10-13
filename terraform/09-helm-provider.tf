data "aws_eks_cluster" "eks_primary" {
  name = aws_eks_cluster.eks_primary.name
  provider = aws.eu-west-1
}

data "aws_eks_cluster_auth" "eks_primary" {
  name = aws_eks_cluster.eks_primary.name
  provider = aws.eu-west-1
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.eks_primary.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_primary.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks_primary.token
  }
  alias = "helm_primary"
  
}

data "aws_eks_cluster" "eks_backup" {
  name = aws_eks_cluster.eks_backup.name
  provider = aws.eu-west-2
}

data "aws_eks_cluster_auth" "eks_backup" {
  name = aws_eks_cluster.eks_backup.name
  provider = aws.eu-west-2
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.eks_backup.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_backup.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks_backup.token
  }
  alias = "helm_backup"
}