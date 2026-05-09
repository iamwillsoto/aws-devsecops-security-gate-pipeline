locals {
  scan_projects = {
    sast = "buildspecs/buildspec-sast.yml"
    sca  = "buildspecs/buildspec-sca.yml"
    iac  = "buildspecs/buildspec-iac.yml"
    dast = "buildspecs/buildspec-dast.yml"
  }
}

resource "aws_codebuild_project" "security_scans" {
  for_each = local.scan_projects

  name          = "${var.project_name}-${each.key}"
  description   = "Security scan stage for ${each.key}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 20

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "REPORT_BUCKET"
      value = aws_s3_bucket.security_reports.bucket
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
  }

  source {
    type      = "GITHUB"
    location  = var.github_repo_url
    buildspec = each.value
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild_logs.name
      status     = "ENABLED"
    }
  }
}
