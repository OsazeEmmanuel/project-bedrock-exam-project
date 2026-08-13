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

############################################
# Cart Service Pod Identity
############################################

data "aws_iam_policy_document" "cart_pod_identity_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "cart" {
  name = "project-bedrock-cart-role"

  assume_role_policy = data.aws_iam_policy_document.cart_pod_identity_trust.json

  tags = {
    Name    = "project-bedrock-cart-role"
    Project = "tinyuka-2025-capstone"
  }
}

data "aws_iam_policy_document" "cart_dynamodb" {
  statement {
    sid    = "CartDynamoDBAccess"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = [
      "arn:aws:dynamodb:us-east-1:470895880196:table/Items"
    ]
  }
}

resource "aws_iam_role_policy" "cart_dynamodb" {
  name = "project-bedrock-cart-dynamodb"
  role = aws_iam_role.cart.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "CartDynamoDBAccess"
      Effect = "Allow"

      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:DescribeTable"
      ]

      Resource = [
        var.dynamodb_table_arn,
        "${var.dynamodb_table_arn}/index/*"
      ]
    }]
  })
}


resource "aws_eks_pod_identity_association" "cart" {
  cluster_name    = var.cluster_name
  namespace       = var.kubernetes_namespace
  service_account = "carts"
  role_arn        = aws_iam_role.cart.arn

  depends_on = [
    aws_iam_role_policy.cart_dynamodb
  ]
}


