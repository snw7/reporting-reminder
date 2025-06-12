#! /bin/bash

# Source the .env file if it exists
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Check if required variables are set
if [ -z "$SERVER_URL" ] || [ -z "$NOTIFICATION_TITLE" ] || [ -z "$NOTIFICATION_MESSAGE" ] || [ -z "$NOTIFICATION_PRIORITY" ] || [ -z "$NOTIFICATION_TAGS" ]; then
    echo "Error: Required variables are not set in .env file"
    exit 1
fi

# Check if SERVER_URL is set
if [ -n "$SERVER_URL" ]; then
    curl \
    -H "Title: $NOTIFICATION_TITLE" \
    -H "Priority: $NOTIFICATION_PRIORITY" \
    -H "Tags: $NOTIFICATION_TAGS" \
    -d "$NOTIFICATION_MESSAGE" \
    "$SERVER_URL"
fi

# Check for notification system and send local notification
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "$NOTIFICATION_TITLE" -message "$NOTIFICATION_MESSAGE"
    else
        echo "Warning: terminal-notifier is not installed. Skipping local notification."
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical "$NOTIFICATION_TITLE" "$NOTIFICATION_MESSAGE"
    else
        echo "Warning: notify-send is not installed. Skipping local notification."
    fi
else
    echo "Warning: Unsupported operating system for local notifications."
fi
