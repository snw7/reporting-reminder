#! /bin/bash

# Source the .env file if it exists
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Check if SERVER_URL is set
if [ -n "$SERVER_URL" ]; then
    curl \
    -H "Title: Reporting" \
    -H "Priority: urgent" \
    -H "Tags: phone" \
    -d "Status needs to be updated. Act right away." \
    "$SERVER_URL"
    
    exit 0
fi

# Check if terminal-notifier is installed
if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "Reporting" -message "Status needs to be updated. Act right away."
else
    echo "Warning: terminal-notifier is not installed. Skipping local notification."
fi
