variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "assets_bucket_arn" {
  description = "ARN of the private assets S3 bucket"
  type        = string
}

variable "developer_username" {
  description = "IAM username for the developer"
  type        = string
  default     = "bedrock-dev-view"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for developer access"
  type        = string
  default     = "retail-app"
}
