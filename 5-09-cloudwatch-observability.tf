# CloudWatch Log Group for EKS Control Plane Logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${local.name}-${var.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_in_days

  tags = {
    Name = "${local.name}-${var.cluster_name}-control-plane-logs"
  }
}

# CloudWatch Log Groups used by Container Insights for workload and node monitoring.
resource "aws_cloudwatch_log_group" "container_insights" {
  for_each = toset(["application", "dataplane", "host", "performance"])

  name              = "/aws/containerinsights/${local.name}-${var.cluster_name}/${each.key}"
  retention_in_days = var.cluster_log_retention_in_days

  tags = {
    Name = "${local.name}-${var.cluster_name}-container-insights-${each.key}"
  }
}

# Look up the latest CloudWatch Observability add-on version for the cluster version.
data "aws_eks_addon_version" "cloudwatch_observability" {
  addon_name         = "amazon-cloudwatch-observability"
  kubernetes_version = aws_eks_cluster.eks_cluster.version
  most_recent        = true
}

# Enable Amazon CloudWatch Observability for Container Insights metrics and logs.
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = data.aws_eks_addon_version.cloudwatch_observability.version

  depends_on = [
    aws_eks_node_group.eks_ng_private,
    aws_cloudwatch_log_group.container_insights,
    aws_iam_role_policy_attachment.eks-CloudWatchAgentServerPolicy,
  ]

  tags = {
    Name = "${local.name}-${var.cluster_name}-cloudwatch-observability"
  }
}
