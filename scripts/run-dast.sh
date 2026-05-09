#!/bin/bash
set -e

echo "Starting DAST scan with OWASP ZAP..."

TARGET_URL=${TARGET_URL:-"https://example.com"}

rm -rf reports
mkdir -p reports
chmod 777 reports

docker run --rm \
  -v "$(pwd)/reports:/zap/wrk/:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t "$TARGET_URL" \
  -J zap-dast-report.json \
  -r zap-dast-report.html \
  || true

echo "Listing generated reports..."
ls -la reports

if [ -f reports/zap-dast-report.json ]; then
  aws s3 cp reports/zap-dast-report.json s3://$REPORT_BUCKET/dast/zap-dast-report.json
else
  echo "ZAP JSON report was not generated."
fi

if [ -f reports/zap-dast-report.html ]; then
  aws s3 cp reports/zap-dast-report.html s3://$REPORT_BUCKET/dast/zap-dast-report.html
else
  echo "ZAP HTML report was not generated."
fi

echo "DAST scan completed."
