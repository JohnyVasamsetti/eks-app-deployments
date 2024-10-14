# control plane role
resource "aws_iam_role" "eks_control_plane_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_control_plane_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_control_plane_role.name
}

# worker node role
resource "aws_iam_role" "worker_node_role" {
  name = "Ec2InstanceWorkerNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_node_role.name
}

# aws alb controller role & policy
resource "aws_iam_role" "aws_alb_controller_role" {
  name = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = {
        Federated = [data.aws_iam_openid_connect_provider.oidc_provider.arn]
      }
    }]
  })
}

resource "aws_iam_policy" "aws_alb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./policies/alb_controller_policy.json")
}

resource "aws_iam_role_policy_attachment" "aws_alb_controller_attachment" {
  policy_arn = aws_iam_policy.aws_alb_controller_policy.arn
  role       = aws_iam_role.aws_alb_controller_role.name
}

# external-dns controller role & policy
resource "aws_iam_role" "external_dns_controller_role" {
  name = "ExternalDnsControllerRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = {
        Federated = [data.aws_iam_openid_connect_provider.oidc_provider.arn]
      }
    }]
  })
}

resource "aws_iam_policy" "external_dns_controller_policy" {
  name = "ExternalDnsController"
  policy = file("./policies/external-dns-controller.json")
}

resource "aws_iam_role_policy_attachment" "external_dns_controller_attachment" {
  policy_arn = aws_iam_policy.external_dns_controller_policy.arn
  role       = aws_iam_role.external_dns_controller_role.name
}