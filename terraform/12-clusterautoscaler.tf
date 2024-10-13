resource "aws_iam_role" "cluster_autoscaler_primary" {
  name = "${aws_eks_cluster.eks_primary.name}-cluster-autoscaler"
  provider = aws.eu-west-1

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cluster_autoscaler_primary" {
  name = "${aws_eks_cluster.eks_primary.name}-cluster-autoscaler"
  provider = aws.eu-west-1

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_primary" {
  policy_arn = aws_iam_policy.cluster_autoscaler_primary.arn
  role       = aws_iam_role.cluster_autoscaler_primary.name
  provider = aws.eu-west-1
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler_primary" {
  cluster_name    = aws_eks_cluster.eks_primary.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler_primary.arn
  provider = aws.eu-west-1
}

resource "helm_release" "cluster_autoscaler_primary" {
  name = "autoscaler"
  provider = helm.helm_primary

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks_primary.name
  }

  # MUST be updated to match your region 
  set {
    name  = "awsRegion"
    value = "eu-west-1"
  }

  depends_on = [helm_release.metrics_server_primary]
}

#####################################################################

resource "aws_iam_role" "cluster_autoscaler_backup" {
  name = "${aws_eks_cluster.eks_backup.name}-cluster-autoscaler"
  provider = aws.eu-west-2

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cluster_autoscaler_backup" {
  name = "${aws_eks_cluster.eks_backup.name}-cluster-autoscaler"
  provider = aws.eu-west-2

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_backup" {
  policy_arn = aws_iam_policy.cluster_autoscaler_backup.arn
  role       = aws_iam_role.cluster_autoscaler_backup.name
  provider = aws.eu-west-2
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler_backup" {
  cluster_name    = aws_eks_cluster.eks_backup.name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler_backup.arn
  provider = aws.eu-west-2
}

resource "helm_release" "cluster_autoscaler_backup" {
  name = "autoscaler"
  provider = helm.helm_backup

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks_backup.name
  }

  # MUST be updated to match your region 
  set {
    name  = "awsRegion"
    value = "eu-west-2"
  }

  depends_on = [helm_release.metrics_server_backup]
}
