variable "table_name" {
  description = "DynamoDB table name for the cart service"
  type        = string
  default     = "Items"
}

variable "project_tag" {
  description = "Project tag applied to resources"
  type        = string
  default     = "tinyuka-2025-capstone"
}
