#!/bin/bash
set -e

echo "Starting DAST scan with OWASP ZAP..."

TARGET_URL=${TARGET_URL:-"https://example.com"}

mkdir -p reports

docker run --rm \
  -v $(pwd)/reports:/zap/wrk/:rw \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t "$TARGET_URL" \
  -J zap-dast-report.json \
  -r zap-dast-report.html \
  || true

aws s3 cp reports/zap-dast-report.json s3://$REPORT_BUCKET/dast/zap-dast-report.json
aws s3 cp reports/zap-dast-report.html s3://$REPORT_BUCKET/dast/zap-dast-report.html

echo "DAST scan completed."
