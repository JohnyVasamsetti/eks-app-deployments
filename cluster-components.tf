resource "aws_eks_cluster" "eks_app_deployment" {
  name = "eks-app-deployment"
  vpc_config {
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id,aws_subnet.public_subnet_1.id,aws_subnet.public_subnet_2.id]
  }
  role_arn = aws_iam_role.eks_control_plane_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  url             = aws_eks_cluster.eks_app_deployment.identity[0].oidc[0].issuer
  thumbprint_list = ["9e99a48a9960b14926bb7f3b01aa618b4c9b3ab7"]
  tags = {
    Name = "eks-oidc-provider"
  }
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = aws_eks_cluster.eks_app_deployment.identity[0].oidc[0].issuer
  depends_on = [aws_iam_openid_connect_provider.oidc_provider]
}

resource "aws_eks_node_group" "cluster-components" {
  node_group_name = "cluster-components"
  cluster_name  = aws_eks_cluster.eks_app_deployment.name
  node_role_arn = aws_iam_role.worker_node_role.arn
  subnet_ids    = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }
  labels = {
    role = "worker",
    workload = "cluster-components",
    Name = "cluster-components"
  }
}

resource "aws_eks_node_group" "app-components" {
  node_group_name = "app-components"
  cluster_name  = aws_eks_cluster.eks_app_deployment.name
  node_role_arn = aws_iam_role.worker_node_role.arn
  subnet_ids    = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
  labels = {
    role = "worker"
    workload = "app-components",
    Name = "cluster-components"
  }
  taint {
    effect = "NO_SCHEDULE"
    key    = "workload"
    value  = "app-components"
  }
}