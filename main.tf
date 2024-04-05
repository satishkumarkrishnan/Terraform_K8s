provider "aws" {
  region = var.region
}

module "asg" {
  source="git@github.com:satishkumarkrishnan/terraform-aws-asg.git?ref=main"  
}

# TF code for EFS resource
resource "aws_eks_cluster" "tokyo_EKS" {
  name     = "Tokyo_EKS"
  role_arn                  = aws_iam_role.tokyo_IAM_EKS_role.arn
  enabled_cluster_log_types = ["api", "audit"]    
  vpc_config {
    subnet_ids = [module.asg.vpc_fe_subnet.id, module.asg.vpc_be_subnet.id]    
  }
  

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
   aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,    
   aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
   aws_cloudwatch_log_group.tokyo_cloud_watch
  ]
}

resource "aws_iam_role" "tokyo_IAM_EKS_role" {
  name               = "tokyo-eks-policy"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

#Resource for EKS IAM Role Policy 
resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tokyo_IAM_EKS_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
#Resource for EKS IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.tokyo_IAM_EKS_role.name
}

# To create cloudwatch log group
resource "aws_cloudwatch_log_group" "tokyo_cloud_watch" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}