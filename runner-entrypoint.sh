#!/bin/bash

set -e

if [ -z "$GITHUB_OWNER" ]; then
    echo "Error: GITHUB_OWNER environment variable is required"
    exit 1
fi

if [ -z "$RUNNER_TOKEN" ]; then
    echo "Error: RUNNER_TOKEN environment variable is required"
    echo "Please run ./setup.sh to generate a registration token"
    exit 1
fi

echo "Starting GitHub Actions Runner..."
echo "Owner: $GITHUB_OWNER"
echo "Repository: ${GITHUB_REPOSITORY:-<org-level>}"
echo "Runner Name: $RUNNER_NAME"
echo "Labels: $RUNNER_LABELS"

exec /opt/runner/bin/Runner.Listener run \
    --startuptype service \
    --once "$@"
