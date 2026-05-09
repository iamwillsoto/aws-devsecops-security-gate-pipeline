#!/bin/bash
set -e

echo "Starting IaC scan with Checkov..."

pip install checkov

mkdir -p reports

checkov -d infra -o json > reports/checkov-iac-report.json || true

FAILED_CHECKS=$(cat reports/checkov-iac-report.json | grep -o '"check_result": {"result": "FAILED"}' | wc -l || true)

echo "Failed IaC checks: $FAILED_CHECKS"

aws s3 cp reports/checkov-iac-report.json s3://$REPORT_BUCKET/iac/checkov-iac-report.json

if [ "$FAILED_CHECKS" -gt 10 ]; then
  echo "IaC gate failed. Too many failed infrastructure security checks."
  exit 1
fi

echo "IaC gate passed."
