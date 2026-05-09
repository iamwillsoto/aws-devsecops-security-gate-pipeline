output "security_reports_bucket" {
  description = "S3 bucket storing DevSecOps security scan reports"
  value       = aws_s3_bucket.security_reports.bucket
}

output "codebuild_project_names" {
  description = "CodeBuild security scan project names"
  value       = [for project in aws_codebuild_project.security_scans : project.name]
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for CodeBuild security scans"
  value       = aws_cloudwatch_log_group.codebuild_logs.name
}
