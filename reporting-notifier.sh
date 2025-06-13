#! /bin/bash

# Get the script's directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Define default log file
DEFAULT_LOG_FILE="logs/reporting-notifier.log"

# Function to log messages with timestamp and level
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp [$level] - $message" | tee -a "$SCRIPT_DIR/$LOG_FILE"
}

# Source the .env file from script directory if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "Error: .env file not found in $SCRIPT_DIR"
    exit 1
fi

# If running as root, switch to the real user
if [ "$(id -u)" -eq 0 ]; then
    log_message "INFO" "Running as root, switching to non-root user"
    # Get the first real user (non-system user)
    REAL_USER=$(dscl . -list /Users UniqueID | awk '$2 >= 500 {print $1}' | head -n 1)
    if [ -n "$REAL_USER" ]; then
        exec su - "$REAL_USER" -c "$0 $*"
        log_message "INFO" "Switched to non-root user: $REAL_USER"
        exit 0
    else
        log_message "CRITICAL" "Error: Could not determine real user"
        exit 1
    fi
fi

# Use LOG_FILE from .env if set, otherwise use default
LOG_FILE=${LOG_FILE:-$DEFAULT_LOG_FILE}

# Create logs directory and log file
mkdir -p "$(dirname "$SCRIPT_DIR/$LOG_FILE")" > /dev/null 2>&1
touch "$SCRIPT_DIR/$LOG_FILE" > /dev/null 2>&1

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
        log_message "INFO" "Ntfy message sent successfully: $SERVER_URL"
    else
        log_message "CRITICAL" "Ntfy message couldn't send"
    fi
fi

# Check for notification system and send local notification
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    # Try to find terminal-notifier in common locations
    TERMINAL_NOTIFIER="/usr/local/bin/terminal-notifier"
    if [ ! -f "$TERMINAL_NOTIFIER" ]; then
        TERMINAL_NOTIFIER="/opt/homebrew/bin/terminal-notifier"
    fi
    
    if [ -f "$TERMINAL_NOTIFIER" ]; then
        if "$TERMINAL_NOTIFIER" -title "$NOTIFICATION_TITLE" -message "$NOTIFICATION_MESSAGE" 2>/dev/null; then
            log_message "INFO" "Local notification sent successfully"
        else
            log_message "CRITICAL" "Failed to send local notification via terminal-notifier"
        fi
    else
        log_message "WARNING" "Dependency terminal-notifier not found in common locations. Skipping local notification."
        log_message "INFO" "Searched in: /usr/local/bin/terminal-notifier and /opt/homebrew/bin/terminal-notifier"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v notify-send >/dev/null 2>&1; then
        if notify-send -u critical "$NOTIFICATION_TITLE" "$NOTIFICATION_MESSAGE" 2>/dev/null; then
            log_message "INFO" "Local notification sent successfully"
        else
            log_message "CRITICAL" "Failed to send local notification via notify-send"
        fi
    else
        log_message "WARNING" "Dependency notify-send is not installed. Skipping local notification."
    fi
else
    log_message "WARNING" "Unsupported operating system for local notifications."
fi
