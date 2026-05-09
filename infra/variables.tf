variable "aws_region" {
  description = "AWS region for the DevSecOps pipeline resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-devsecops-security-gate"
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}
