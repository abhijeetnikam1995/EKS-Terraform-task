# CloudWatch Log Group for EKS Control Plane Logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${local.eks_cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days

  tags = local.common_tags
}

# CloudWatch Observability Add-on for EKS Container Insights and metrics
resource "aws_eks_addon" "cloudwatch_observability" {
  count = var.enable_cloudwatch_observability ? 1 : 0

  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.eks-CloudWatchAgentServerPolicy,
    aws_iam_role_policy_attachment.eks-AWSXrayWriteOnlyAccess,
  ]

  tags = local.common_tags
}
