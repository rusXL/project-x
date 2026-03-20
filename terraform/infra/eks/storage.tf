# Pod Identity addon
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.cluster_a.name
  addon_name   = "eks-pod-identity-agent"
  depends_on   = [aws_eks_node_group.node_group_a]
}

# IAM role for EBS CSI driver
resource "aws_iam_role" "ebs_csi" {
  name = "eks-ebs-csi-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

# Associate role with EBS CSI service account via Pod Identity
resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = aws_eks_cluster.cluster_a.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn
}

# EBS CSI addon
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.cluster_a.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on = [
    aws_eks_addon.pod_identity,
    aws_eks_pod_identity_association.ebs_csi,
    aws_eks_node_group.node_group_a,
  ]
}
