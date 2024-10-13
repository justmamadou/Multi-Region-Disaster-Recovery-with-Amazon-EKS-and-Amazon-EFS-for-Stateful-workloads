resource "helm_release" "metrics_server_primary" {
  name = "metrics-server"
  provider = helm.helm_primary

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"
  namespace = "kube-system"
  version = "3.12.1"

  values = [ file("${path.module}/values/metrics-server.yaml") ]

  depends_on = [ aws_eks_node_group.general_primary, aws_eks_node_group.general_backup ]
}

resource "helm_release" "metrics_server_backup" {
  name = "metrics-server"
  provider = helm.helm_backup

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart = "metrics-server"
  namespace = "kube-system"
  version = "3.12.1"

  values = [ file("${path.module}/values/metrics-server.yaml") ]

  depends_on = [ aws_eks_node_group.general_primary, aws_eks_node_group.general_backup ]
}