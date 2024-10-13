data "aws_iam_policy_document" "aws_lbc_primary" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
  provider = aws.eu-west-1
}

resource "aws_iam_role" "aws_lbc_primary" {
  name               = "${aws_eks_cluster.eks_primary.name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc_primary.json
  provider = aws.eu-west-1
}

resource "aws_iam_policy" "aws_lbc_primary" {
  policy = file("./iam/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
  provider = aws.eu-west-1
}

resource "aws_iam_role_policy_attachment" "aws_lbc_primary" {
  policy_arn = aws_iam_policy.aws_lbc_primary.arn
  role       = aws_iam_role.aws_lbc_primary.name
  provider = aws.eu-west-1
}

resource "aws_eks_pod_identity_association" "aws_lbc_primary" {
  cluster_name    = aws_eks_cluster.eks_primary.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc_primary.arn
  provider = aws.eu-west-1
}

resource "helm_release" "aws_lbc_primary" {
  name = "aws-load-balancer-controller"
  provider = helm.helm_primary
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_primary.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "serviceAccount.create"
    value = true
  }

  set {
    name  = "vpcId"
    value = aws_vpc.primary.id 
  }

  depends_on = [helm_release.cluster_autoscaler_primary]
}


##############################################################
data "aws_iam_policy_document" "aws_lbc_backup" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
  provider = aws.eu-west-2
}

resource "aws_iam_role" "aws_lbc_backup" {
  name               = "${aws_eks_cluster.eks_backup.name}-aws-lbc"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc_backup.json
  provider = aws.eu-west-2
}

resource "aws_iam_policy" "aws_lbc_backup" {
  policy = file("./iam/AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
  provider = aws.eu-west-2
}

resource "aws_iam_role_policy_attachment" "aws_lbc_backup" {
  policy_arn = aws_iam_policy.aws_lbc_backup.arn
  role       = aws_iam_role.aws_lbc_backup.name
  provider = aws.eu-west-2
}

resource "aws_eks_pod_identity_association" "aws_lbc_backup" {
  cluster_name    = aws_eks_cluster.eks_backup.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.aws_lbc_backup.arn
  provider = aws.eu-west-2
}

resource "helm_release" "aws_lbc_backup" {
  name = "aws-load-balancer-controller"
  provider = helm.helm_backup

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_backup.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "serviceAccount.create"
    value = true
  }

  set {
    name  = "vpcId"
    value = aws_vpc.backup.id 
  }

  depends_on = [helm_release.cluster_autoscaler_backup]
}