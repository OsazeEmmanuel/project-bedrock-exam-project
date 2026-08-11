############################################
# Developer IAM User
############################################

resource "aws_iam_user" "developer" {
  name          = var.developer_username
  force_destroy = true

  tags = {
    Name    = var.developer_username
    Project = "tinyuka-2025-capstone"
  }
}

############################################
# AWS Console Login Profile
############################################

resource "aws_iam_user_login_profile" "developer" {
  user                    = aws_iam_user.developer.name
  password_length         = 20
  password_reset_required = true
}

############################################
# AWS Read-Only Console Access
############################################

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.developer.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

############################################
# Developer Access Key
############################################

resource "aws_iam_access_key" "developer" {
  user = aws_iam_user.developer.name
}

############################################
# S3 Upload Permission
############################################

resource "aws_iam_user_policy" "s3_upload" {
  name = "bedrock-dev-view-s3-upload"
  user = aws_iam_user.developer.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowAssetUpload"
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${var.assets_bucket_arn}/*"
      }
    ]
  })
}

############################################
# EKS Access Entry
############################################

resource "aws_eks_access_entry" "developer" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.developer.arn

  type = "STANDARD"

  tags = {
    Name    = "bedrock-dev-view-access"
    Project = "tinyuka-2025-capstone"
  }
}

############################################
# EKS Read-Only Policy Association
############################################

resource "aws_eks_access_policy_association" "developer_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.developer.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "namespace"

    namespaces = [
      var.kubernetes_namespace
    ]
  }

  depends_on = [
    aws_eks_access_entry.developer
  ]
}
