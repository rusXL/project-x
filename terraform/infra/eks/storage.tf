# for PVCs

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.cluster_a.name
  addon_name   = "aws-ebs-csi-driver"
  depends_on = [
    aws_iam_role_policy_attachment.eks_ebs_csi_policy,
    aws_eks_node_group.node_group_a
  ]
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "eks-nodes-"
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}
