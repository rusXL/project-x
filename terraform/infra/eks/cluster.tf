# k8s clusters

# IAM role for EKS control plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# IAM role for node group
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# EKS cluster
resource "aws_eks_cluster" "cluster_a" {
  name     = "cluster-a"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet_a.id,
      aws_subnet.subnet_b.id,
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Node group
resource "aws_eks_node_group" "node_group_a" {
  cluster_name    = aws_eks_cluster.cluster_a.name
  node_group_name = "node-group-a"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    aws_subnet.subnet_a.id,
    aws_subnet.subnet_b.id,
  ]
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = var.aws_node_count
    min_size     = 3
    max_size     = var.aws_node_count
  }

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
  ]
}
