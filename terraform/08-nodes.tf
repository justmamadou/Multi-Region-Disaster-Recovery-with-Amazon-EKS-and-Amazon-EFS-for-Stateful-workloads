resource "aws_iam_role" "nodes_primary" {
  name = "${local.env1}-${local.eks_name}-eks-nodes"
  provider = aws.eu-west-1
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
      ]
    }
    POLICY
}

# This polcy now includes AssumeRoleForPodIdentity for the pod Identity Agent
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_primary" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.nodes_primary.name
  provider = aws.eu-west-1
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_primary" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.nodes_primary.name
  provider = aws.eu-west-1
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only_primary" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.nodes_primary.name
  provider = aws.eu-west-1
}

resource "aws_eks_node_group" "general_primary" {
  cluster_name = aws_eks_cluster.eks_primary.name
  version = local.eks_version
  node_group_name = "general"
  node_role_arn = aws_iam_role.nodes_primary.arn
  provider = aws.eu-west-1

  subnet_ids = [ 
    aws_subnet.private_zone1-primary.id,
    aws_subnet.private_zone2-primary.id
  ]

  capacity_type = "ON_DEMAND"
  instance_types = [ "t3.large" ]

  scaling_config {
    desired_size = 1
    max_size = 10
    min_size = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_primary,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only_primary,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_primary
   ]
   
   // Allow external changes without Terraform plan difference
   lifecycle {
     ignore_changes = [ scaling_config[0].desired_size ]
   }

}
 


/************************* backup ******/
resource "aws_iam_role" "nodes_backup" {
  name = "${local.env2}-${local.eks_name}-eks-nodes"
  provider = aws.eu-west-2
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
      ]
    }
    POLICY
}

# This polcy now includes AssumeRoleForPodIdentity for the pod Identity Agent
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.nodes_backup.name
  provider = aws.eu-west-2
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.nodes_backup.name
  provider = aws.eu-west-2
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only_backup" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.nodes_backup.name
  provider = aws.eu-west-2
}

resource "aws_eks_node_group" "general_backup" {
  cluster_name = aws_eks_cluster.eks_backup.name
  version = local.eks_version
  node_group_name = "general"
  node_role_arn = aws_iam_role.nodes_backup.arn
  provider = aws.eu-west-2

  subnet_ids = [ 
    aws_subnet.private_zone1-backup.id,
    aws_subnet.private_zone2-backup.id
  ]

  capacity_type = "ON_DEMAND"
  instance_types = [ "t3.large" ]

  scaling_config {
    desired_size = 1
    max_size = 10
    min_size = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_backup,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only_backup,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_backup 
   ]
   
   // Allow external changes without Terraform plan difference
   lifecycle {
     ignore_changes = [ scaling_config[0].desired_size ]
   }

}
 

