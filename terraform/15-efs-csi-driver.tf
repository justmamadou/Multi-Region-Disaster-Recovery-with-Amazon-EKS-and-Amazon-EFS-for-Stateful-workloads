// Creation du file system
resource "aws_efs_file_system" "eks_primary" {
  creation_token = "eks"
  provider = aws.eu-west-1

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # lifecycle_policy {
  #   transition_to_ia = "AFTER_30_DAYS"
  # }
}

// Creation des mounts target
resource "aws_efs_mount_target" "zone_a_primary" {
  file_system_id  = aws_efs_file_system.eks_primary.id
  subnet_id       = aws_subnet.private_zone1-primary.id
  security_groups = [aws_eks_cluster.eks_primary.vpc_config[0].cluster_security_group_id]
  provider = aws.eu-west-1
}

resource "aws_efs_mount_target" "zone_b_primary" {
  file_system_id  = aws_efs_file_system.eks_primary.id
  subnet_id       = aws_subnet.private_zone2-primary.id
  security_groups = [aws_eks_cluster.eks_primary.vpc_config[0].cluster_security_group_id]
  provider = aws.eu-west-1
}


data "aws_iam_policy_document" "efs_csi_driver_primary" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_primary.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_primary.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs_csi_driver_primary" {
  name               = "${aws_eks_cluster.eks_primary.name}-efs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_primary.json
  provider = aws.eu-west-1
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_primary" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver_primary.name
  provider = aws.eu-west-1
}

resource "helm_release" "efs_csi_driver_primary" {
  name = "aws-efs-csi-driver"
  provider = helm.helm_primary

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = "3.0.3"

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver_primary.arn
  }

  depends_on = [
    aws_efs_mount_target.zone_a_primary,
    aws_efs_mount_target.zone_b_primary
  ]
}

# Optional since we already init helm provider (just to make it self contained)
data "aws_eks_cluster" "eks_v2_primary" {
  name = aws_eks_cluster.eks_primary.name
}

# Optional since we already init helm provider (just to make it self contained)
data "aws_eks_cluster_auth" "eks_v2_primary" {
  name = aws_eks_cluster.eks_primary.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_v2_primary.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_v2_primary.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_v2_primary.token
  alias = "kubernetes-primary"
}

resource "kubernetes_storage_class_v1" "efs_primary" {
  metadata {
    name = "efs"
  }
  provider = kubernetes.kubernetes-primary

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks_primary.id
    directoryPerms   = "700"
  }

  mount_options = ["iam"]

  depends_on = [helm_release.efs_csi_driver_primary]
}


##################################################################
// Creation du file system
resource "aws_efs_file_system" "eks_backup" {
  creation_token = "eks"
  provider = aws.eu-west-2

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # lifecycle_policy {
  #   transition_to_ia = "AFTER_30_DAYS"
  # }
}

// Creation des mounts target
resource "aws_efs_mount_target" "zone_a_backup" {
  file_system_id  = aws_efs_file_system.eks_backup.id
  subnet_id       = aws_subnet.private_zone1-backup.id
  security_groups = [aws_eks_cluster.eks_backup.vpc_config[0].cluster_security_group_id]
  provider = aws.eu-west-2
}

resource "aws_efs_mount_target" "zone_b_backup" {
  file_system_id  = aws_efs_file_system.eks_backup.id
  subnet_id       = aws_subnet.private_zone2-backup.id
  security_groups = [aws_eks_cluster.eks_backup.vpc_config[0].cluster_security_group_id]
  provider = aws.eu-west-2
}

data "aws_iam_policy_document" "efs_csi_driver_backup" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_backup.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_backup.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs_csi_driver_backup" {
  name               = "${aws_eks_cluster.eks_backup.name}-efs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_backup.json
  provider = aws.eu-west-2
}

resource "aws_iam_role_policy_attachment" "efs_csi_driver_backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver_backup.name
  provider = aws.eu-west-2
}

resource "helm_release" "efs_csi_driver_backup" {
  name = "aws-efs-csi-driver"
  provider = helm.helm_backup

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = "3.0.3"

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver_backup.arn
  }

  depends_on = [
    aws_efs_mount_target.zone_a_backup,
    aws_efs_mount_target.zone_b_backup
  ]
}

# Optional since we already init helm provider (just to make it self contained)
data "aws_eks_cluster" "eks_v2_backup" {
  name = aws_eks_cluster.eks_backup.name
  provider = aws.eu-west-2
}


# Optional since we already init helm provider (just to make it self contained)
data "aws_eks_cluster_auth" "eks_v2_backup" {
  name = aws_eks_cluster.eks_backup.name
  provider = aws.eu-west-2
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_v2_backup.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_v2_backup.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_v2_backup.token
  alias = "kubernetes-backup"
}


resource "kubernetes_storage_class_v1" "efs_backup" {
  metadata {
    name = "efs"
  }
  provider = kubernetes.kubernetes-backup

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks_backup.id
    directoryPerms   = "700"
  }

  mount_options = ["iam"]

  depends_on = [helm_release.efs_csi_driver_backup]
} 