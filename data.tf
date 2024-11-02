data "aws_iam_openid_connect_provider" "oidc_provider" {
  url        = aws_eks_cluster.eks_app_deployment.identity[0].oidc[0].issuer
  depends_on = [aws_iam_openid_connect_provider.oidc_provider]
}

