// Install Pod Identity Agent
resource "aws_eks_addon" "pod_identity_primary" {
  cluster_name = aws_eks_cluster.eks_primary.name
  addon_name = "eks-pod-identity-agent"
  addon_version = "v1.3.2-eksbuild.2"
  provider = aws.eu-west-1
}

resource "aws_eks_addon" "pod_identity_backup" {
  cluster_name = aws_eks_cluster.eks_backup.name
  addon_name = "eks-pod-identity-agent"
  addon_version = "v1.3.2-eksbuild.2"
  provider = aws.eu-west-2
}




