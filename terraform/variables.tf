variable "aws_region" {
  description = "AWS region used for the project infrastructure"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Project name used as a prefix for AWS resources"
  type        = string
  default     = "aws-eks-cicd"
}

variable "github_repository_subject" {
  description = "GitHub OIDC subject allowed to assume the CI/CD IAM role"
  type        = string
}