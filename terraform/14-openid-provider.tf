data "tls_certificate" "eks_primary" {
  url = aws_eks_cluster.eks_primary.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_primary" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_primary.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_primary.identity[0].oidc[0].issuer
  provider = aws.eu-west-1
}

###################################################

data "tls_certificate" "eks_backup" {
  url = aws_eks_cluster.eks_backup.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_backup" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_backup.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_backup.identity[0].oidc[0].issuer
  provider = aws.eu-west-2
}