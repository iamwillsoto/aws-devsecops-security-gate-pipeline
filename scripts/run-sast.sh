#!/bin/bash
set -e

echo "Starting SAST scan with SonarCloud..."

if [ -z "$SONAR_TOKEN" ]; then
  echo "SONAR_TOKEN is not configured."
  exit 1
fi

npm install -g sonar-scanner

sonar-scanner \
  -Dsonar.projectKey=$SONAR_PROJECT_KEY \
  -Dsonar.organization=$SONAR_ORG \
  -Dsonar.sources=app \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.login=$SONAR_TOKEN

echo "SAST scan completed."
