// Creation du role pour eks
resource "aws_iam_role" "eks_primary" {
  name = "${local.env1}-${local.eks_name}-eks-cluster"
  provider = aws.eu-west-1

  assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
      ]
    }
  POLICY
}

// Attachement de la policy au role
resource "aws_iam_role_policy_attachment" "eks_primary" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_primary.name
  provider = aws.eu-west-1
}

// Creation du cluster eks

resource "aws_eks_cluster" "eks_primary" {
  name = "${local.env1}-${local.eks_name}"
  version = local.eks_version
  role_arn = aws_iam_role.eks_primary.arn
  provider = aws.eu-west-1

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true

    subnet_ids = [ 
        aws_subnet.private_zone1-primary.id,
        aws_subnet.private_zone2-primary.id
    ]
  }

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_primary ]

}

/*********************************** Backup *************************/
// Creation du role pour eks
resource "aws_iam_role" "eks_backup" {
  name = "${local.env2}-${local.eks_name}-eks-cluster"
  provider = aws.eu-west-2

  assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
      ]
    }
  POLICY
}

// Attachement de la policy au role
resource "aws_iam_role_policy_attachment" "eks_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_backup.name
  provider = aws.eu-west-2
}

// Creation du cluster eks

resource "aws_eks_cluster" "eks_backup" {
  name = "${local.env2}-${local.eks_name}"
  version = local.eks_version
  role_arn = aws_iam_role.eks_backup.arn
  provider = aws.eu-west-2

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true

    subnet_ids = [ 
        aws_subnet.private_zone1-backup.id,
        aws_subnet.private_zone2-backup.id
    ]
  }

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [ aws_iam_role_policy_attachment.eks_backup ]

}