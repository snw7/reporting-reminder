#! /bin/bash

# Function to log messages with timestamp and level
log_message() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] - $message"
}

# Source the .env file if it exists
if [ -f .env ]; then
    source .env
else
    log_message "CRITICAL" "Error: .env file not found"
    exit 1
fi

# Check if required variables are set
if [ -z "$SERVER_URL" ] || [ -z "$NOTIFICATION_TITLE" ] || [ -z "$NOTIFICATION_MESSAGE" ] || [ -z "$NOTIFICATION_PRIORITY" ] || [ -z "$NOTIFICATION_TAGS" ]; then
    log_message "CRITICAL" "Error: Required variables are not set in .env file"
    exit 1
fi

# Check if SERVER_URL is set
if [ -n "$SERVER_URL" ]; then
    if curl -s --max-time 5 \
    -H "Title: $NOTIFICATION_TITLE" \
    -H "Priority: $NOTIFICATION_PRIORITY" \
    -H "Tags: $NOTIFICATION_TAGS" \
    -d "$NOTIFICATION_MESSAGE" \
    "$SERVER_URL" > /dev/null; then
        log_message "INFO" "ntfy message sent successfully: $SERVER_URL"
    else
        log_message "CRITICAL" "ntfy message couldn't send"
    fi
fi

# Check for notification system and send local notification
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v terminal-notifier >/dev/null 2>&1; then
        if terminal-notifier -title "$NOTIFICATION_TITLE" -message "$NOTIFICATION_MESSAGE" 2>/dev/null; then
            log_message "INFO" "local notification sent successfully"
        else
            log_message "CRITICAL" "Failed to send local notification via terminal-notifier"
        fi
    else
        log_message "WARNING" "terminal-notifier is not installed. Skipping local notification."
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v notify-send >/dev/null 2>&1; then
        if notify-send -u critical "$NOTIFICATION_TITLE" "$NOTIFICATION_MESSAGE" 2>/dev/null; then
            log_message "INFO" "local notification sent successfully"
        else
            log_message "CRITICAL" "Failed to send local notification via notify-send"
        fi
    else
        log_message "WARNING" "notify-send is not installed. Skipping local notification."
    fi
else
    log_message "WARNING" "Unsupported operating system for local notifications."
fi
