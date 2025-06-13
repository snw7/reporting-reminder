# Reporting Notifier

A notification service that sends messages to ntfy and local system notifications (macOS/Linux).

## Getting Ready

1. If you do not host your own ntfy server create an account on [ntfy.sh](ntfy.sh)
2. Create a new topic for this use case
3. Download the `ntfy` app to your phone and subscribe to your topic (enable push notifications here)
4. Clone this Repository

```bash
git clone https://github.com/snw7/reporting-reminder.git
```

## Quick Start

1. Copy the example environment file and configure it:

```bash
cp .env.example .env
```

2. Edit the `.env` file with your settings
3. Run the script:

```bash
./reporting-notifier.sh
```

#### Automation - Create a cronjob

4. Open your cronjobs

```bash
crontab -e
```

5. Insert the job according to your specification. The example executes a script hourly on weekdays from 08.00 to 16.00 at minute 25

```bash
25 8-16 * * 1-5 /Users/path-to-your-script/reporting-notifier.sh
```

Hint: To get the location of your scribt run `pwd -P`

## Features

- Sends notifications to ntfy server
- Local system notifications on macOS and Linux
- Configurable via `.env` file
- Structured logging system
- Error handling and timeout protection
- Can be run manually or via cronjob
- Automatic log file creation and management
- Support for custom log file locations

## Requirements

### macOS

- terminal-notifier (for local notifications)
- curl (for ntfy notifications)

### Linux

- notify-send (for local notifications)
- curl (for ntfy notifications)

## Logging

The script uses a structured logging system that writes to both console and log file.

### Log Levels

- `[INFO]` - Successful operations
- `[WARNING]` - Non-critical issues
- `[CRITICAL]` - Critical errors

### Log Format

```
YYYY-MM-DD HH:MM:SS [LEVEL] - Message
```

### Log File

- Default location: `logs/reporting-notifier.log`
- Customizable via `LOG_FILE` in `.env`
- Automatically created if it doesn't exist
- Directory structure is automatically created

## Error Handling

The script includes error handling for:

- Missing `.env` file
- Missing required variables
- Failed ntfy notifications
- Failed local notifications
- Missing notification tools
- Network timeouts (5s)

## Installation

### macOS

```bash
brew install terminal-notifier
```

### Linux

```bash
# Ubuntu/Debian
sudo apt-get install libnotify-bin

# Fedora
sudo dnf install libnotify

# Arch Linux
sudo pacman -S libnotify
```
