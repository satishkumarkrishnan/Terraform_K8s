/*data "aws_eks_cluster" "example" {
  name = "example"
}*/
data "aws_eks_cluster_auth" "example" {
  name = "example"
}

# Allow EKS instances to assume the role
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

  }
}

# Create the policy which allows other actions for the EKS instance
data "aws_iam_policy_document" "eks_access_role_policy" {
  statement {
    actions = [
      "eks:ListFargateProfiles",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "eks:AccessKubernetesApi",
      "eks:ListAddons",
      "eks:DescribeCluster",
      "eks:DescribeAddonVersions",
      "eks:ListClusters",
      "eks:ListIdentityProviderConfigs",
      "iam:ListRoles"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}