#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

source "$ENV_FILE"

if [ -z "$GITHUB_OWNER" ]; then
    echo "Error: GITHUB_OWNER is not set in .env file"
    exit 1
fi

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: ACCESS_TOKEN is not set in .env file"
    exit 1
fi

echo "Getting runner registration token..."

if [ -z "$GITHUB_REPOSITORY" ]; then
    echo "Registering runner for user/organization: $GITHUB_OWNER"
    
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $ACCESS_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/users/$GITHUB_OWNER/actions/runners/registration-token")
    
    if echo "$RESPONSE" | grep -q '"message"'; then
        echo "User endpoint failed, trying org endpoint..."
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: token $ACCESS_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/orgs/$GITHUB_OWNER/actions/runners/registration-token")
    fi
else
    echo "Registering runner for repository: $GITHUB_OWNER/$GITHUB_REPOSITORY"
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $ACCESS_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPOSITORY/actions/runners/registration-token")
fi

if echo "$RESPONSE" | grep -q '"token"'; then
    REGISTRATION_TOKEN=$(echo "$RESPONSE" | jq -r '.token')
    
    if [ -z "$REGISTRATION_TOKEN" ] || [ "$REGISTRATION_TOKEN" = "null" ]; then
        echo "Error: Failed to extract token from response"
        echo "Response: $RESPONSE"
        exit 1
    fi
    
    echo "Registration token generated successfully"
    
    if grep -q "^REGISTRATION_TOKEN=" "$ENV_FILE"; then
        sed -i "s/^REGISTRATION_TOKEN=.*/REGISTRATION_TOKEN=$REGISTRATION_TOKEN/" "$ENV_FILE"
    else
        echo "REGISTRATION_TOKEN=$REGISTRATION_TOKEN" >> "$ENV_FILE"
    fi
    
    echo "Updated .env file with registration token"
    echo ""
    echo "You can now start the runner with: docker compose up -d"
else
    echo "Error: Failed to get registration token"
    echo "Response: $RESPONSE"
    exit 1
fi
