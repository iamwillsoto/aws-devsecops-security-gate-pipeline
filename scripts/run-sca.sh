#!/bin/bash
set -e

echo "Starting SCA scan with Snyk..."

if [ -z "$SNYK_TOKEN" ]; then
  echo "SNYK_TOKEN is not configured."
  exit 1
fi

cd app
npm install

npm install -g snyk
snyk auth "$SNYK_TOKEN"

mkdir -p ../reports

snyk test --json > ../reports/snyk-sca-report.json || true

CRITICAL_COUNT=$(cat ../reports/snyk-sca-report.json | grep -o '"severity":"critical"' | wc -l || true)
HIGH_COUNT=$(cat ../reports/snyk-sca-report.json | grep -o '"severity":"high"' | wc -l || true)

echo "Critical findings: $CRITICAL_COUNT"
echo "High findings: $HIGH_COUNT"

aws s3 cp ../reports/snyk-sca-report.json s3://$REPORT_BUCKET/sca/snyk-sca-report.json

if [ "$CRITICAL_COUNT" -gt 0 ]; then
  echo "SCA gate failed due to critical vulnerabilities."
  exit 1
fi

echo "SCA gate passed."
