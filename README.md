# AWS DevSecOps Security Gate Pipeline

An AWS-native DevSecOps pipeline that validates application code, open-source dependencies, Terraform infrastructure, and running web endpoints before release.

---

## Problem

Software delivery pipelines move faster than manual security review. Vulnerable application code, exposed dependencies, misconfigured Terraform resources, and unscanned web endpoints can be promoted before any control catches them.

For cloud teams, this creates release risk, operational risk, and weak audit evidence. Security validation needs to run as part of the delivery workflow — not after deployment.

## Solution

AWS DevSecOps Security Gate Pipeline executes pre-release security validation as an automated control loop:

```
source → scan → evaluate → store evidence → log execution → gate
```

AWS CodeBuild orchestrates four security scan stages directly from the repository, each driven by a dedicated buildspec:

- **SAST** with SonarQube Cloud
- **SCA** with Snyk
- **IaC** with Checkov
- **DAST** with OWASP ZAP

Scan reports persist to Amazon S3 as security evidence. Execution logs centralize in CloudWatch. AWS Security Hub, GuardDuty, Inspector, and IAM Access Analyzer extend visibility into the runtime AWS environment alongside CI/CD scanning.

---

## Architecture

![AWS DevSecOps Security Gate Pipeline](architecture/aws-devsecops-security-gate-pipeline.png)

---

## Stack

| Layer | Service / Tool |
|---|---|
| Source Repository | GitHub |
| Scan Execution | AWS CodeBuild |
| Static Code Analysis | SonarQube Cloud |
| Dependency Scanning | Snyk |
| Infrastructure-as-Code Scanning | Checkov |
| Dynamic Web Scanning | OWASP ZAP |
| Evidence Storage | Amazon S3 (SSE-S3, versioned, Block Public Access) |
| Observability | Amazon CloudWatch Logs |
| Cloud Security Visibility | AWS Security Hub, GuardDuty, Inspector, IAM Access Analyzer |
| Infrastructure | Terraform |
| Access Control | AWS IAM |

---

## Security Gate Flow

```
GitHub repository
        ↓
AWS CodeBuild pulls source
        ↓
SAST scan runs with SonarQube Cloud
        ↓
SCA scan runs with Snyk
        ↓
IaC scan runs with Checkov
        ↓
DAST scan runs with OWASP ZAP
        ↓
Scan reports upload to Amazon S3
        ↓
Execution logs write to CloudWatch
        ↓
Build status reflects pass/fail security validation
```

---

## Scan Controls

Each scan runs as its own CodeBuild project with a dedicated buildspec. Separating stages keeps each control independently testable, debuggable, and explainable.

| Control | Tool | Buildspec |
|---|---|---|
| Static application security testing | SonarQube Cloud | `buildspec-sast.yml` |
| Software composition analysis | Snyk | `buildspec-sca.yml` |
| Infrastructure-as-code scanning | Checkov | `buildspec-iac.yml` |
| Dynamic application security testing | OWASP ZAP | `buildspec-dast.yml` |

---

## AWS Security Visibility Layer

Alongside the CI/CD scan stages, four AWS-native security services run continuously:

- **AWS Security Hub** — centralized security posture visibility
- **Amazon GuardDuty** — threat detection across CloudTrail, DNS, and VPC activity
- **Amazon Inspector** — vulnerability scanning for EC2, ECR, and Lambda
- **IAM Access Analyzer** — external access review for resource policies

These services demonstrate how pipeline-level controls operate alongside AWS-native runtime visibility — the prevention side of cloud security paired with continuous detection.

---

## Evidence and Observability

Security reports are stored in an S3 bucket with server-side encryption (SSE-S3), versioning, and Block Public Access enabled. Each CodeBuild execution writes structured logs to CloudWatch under the project log group, preserving full scan run history.

CodeBuild build status communicates the security gate decision for each scan stage: a passing build means that control met its threshold; a failing build represents a blocking finding or execution issue that requires review.

---

## Validation

The pipeline was validated through dedicated CodeBuild scan jobs against the sample application and Terraform infrastructure.

| Stage | Result |
|---|---|
| SonarQube Cloud SAST | Source analysis completed; dashboard captured |
| Snyk SCA | Dependency scan executed against the sample app |
| Checkov IaC | Terraform scan executed through CodeBuild |
| OWASP ZAP DAST | Web endpoint scan completed; reports uploaded to S3 |
| S3 evidence storage | Scan reports persisted in the reports bucket |
| CloudWatch Logs | CodeBuild execution logs centralized under the project log group |
| Security Hub | Enabled for centralized posture visibility |
| GuardDuty | Enabled for AWS-native threat detection |
| Inspector | Enabled for vulnerability visibility |
| IAM Access Analyzer | External access analyzer created in `us-east-1` |

The initial DAST run failed because the OWASP ZAP container could not write reports to the mounted directory. The scan script was updated to recreate the reports directory with write permissions before launching the container. The corrected DAST scan completed successfully and uploaded artifacts to S3.

---

## Security Design Principles

- Source-driven security validation — scans run from the repository, not post-deployment
- Separation of concerns — each control owns one CodeBuild project and one buildspec
- Least-privilege IAM — scoped CodeBuild service role permissions
- Durable security evidence — versioned S3 reports with Block Public Access
- Centralized execution logs — CloudWatch log streams for CodeBuild scan executions
- IaC-only infrastructure — Terraform-managed CodeBuild projects, S3 buckets, and IAM roles
- AWS-native visibility — Security Hub, GuardDuty, Inspector, and IAM Access Analyzer enabled alongside pipeline scans
- Self-validating IaC — Checkov scans the project's own Terraform configuration

---

## Scope and Limitations

This implementation is scoped to a single AWS account and one repository. It demonstrates pre-release security validation using AWS-native build execution and four third-party security tools.

The DAST stage scans a configured target URL. In a production implementation, the target would be a staging endpoint deployed earlier in the pipeline.

Encryption uses S3 server-side encryption (SSE-S3) and AWS-managed CloudWatch Logs encryption. Customer-managed KMS keys are an enhancement path, not part of the current implementation.

Production expansion paths include CodePipeline orchestration, AWS Secrets Manager for token storage, customer-managed KMS keys for scan evidence, automated ticket creation on findings, Security Hub finding ingestion, and multi-account rollout through AWS Organizations.

---

## Repository Structure

```text
aws-devsecops-security-gate-pipeline/
├── app/
│   ├── package.json
│   ├── package-lock.json
│   └── server.js
├── architecture/
│   └── aws-devsecops-security-gate-pipeline.png
├── buildspecs/
│   ├── buildspec-dast.yml
│   ├── buildspec-iac.yml
│   ├── buildspec-sast.yml
│   └── buildspec-sca.yml
├── infra/
│   ├── codebuild.tf
│   ├── iam.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── s3.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
├── scripts/
│   ├── run-dast.sh
│   ├── run-iac-scan.sh
│   ├── run-sast.sh
│   └── run-sca.sh
├── validation-screenshots/
├── .gitignore
└── README.md
```

---

## Project Outcome

AWS DevSecOps Security Gate Pipeline embeds security validation directly into the delivery workflow rather than relying on post-deployment review.

The project validates practical experience with AWS CodeBuild scan execution, SAST, SCA, IaC, and DAST security testing, SonarQube Cloud, Snyk, Checkov, and OWASP ZAP integration, S3-backed evidence storage, CloudWatch-based observability, AWS Security Hub posture visibility, and Terraform-managed AWS infrastructure.

It demonstrates pre-release security control across code, dependencies, infrastructure, and endpoints — identifying insecure patterns before they reach production rather than detecting them afterward.