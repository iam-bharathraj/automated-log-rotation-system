#!/bin/bash

set -e

# Variables
BASE="$HOME/practice_directory"
ARCHIVE="$BASE/archive"
DEPTH=1
RUN=1
THRESHOLD=80
EMAIL="your_email@example.com" # update  before use

# Check if directory exists
if [ ! -d "$BASE" ]; then
    echo "Directory does not exist: $BASE"
    exit 1
fi

# Check disk usage
USAGE=$(df "$BASE" | awk 'NR==2 {print $5}' | tr -d '%')
echo "Current disk usage: $USAGE%"

# Skip cleanup if below threshold
if [ "$USAGE" -lt "$THRESHOLD" ]; then
    echo "Disk usage is below ${THRESHOLD}%. Skipping cleanup."

    FREE_SPACE=$(df -h "$BASE" | awk 'NR==2 {print $4}')

    EMAIL_BODY="Disk usage is ${USAGE}% (below threshold)
No cleanup performed
Free Space: ${FREE_SPACE}"

    echo -e "$EMAIL_BODY" | mail -s "Log Rotation Skipped" "$EMAIL"
    exit 0
fi

echo "Disk usage is above ${THRESHOLD}%. Running cleanup..."

# Create archive directory
if [ ! -d "$ARCHIVE" ]; then
    mkdir -p "$ARCHIVE"
fi

FILES=""

# Find files larger than 10MB and archive them
while IFS= read -r file
do
    echo "Processing file: $file"

    if [ "$RUN" -ne 0 ]; then
        gzip "$file"
        mv "$file.gz" "$ARCHIVE"
        FILES="${FILES}\n$(basename "$file").gz"
    fi
done < <(find "$BASE" -maxdepth "$DEPTH" -type f -size +10M ! -path "$ARCHIVE/*" ! -name "*.gz")

# Check free space
FREE_SPACE=$(df -h "$BASE" | awk 'NR==2 {print $4}')

if [ -z "$FILES" ]; then
    FILES="No files were archived"
fi

# Email report
EMAIL_BODY="Log Rotation Report

Disk Usage: ${USAGE}%
Free Space: ${FREE_SPACE}

Archived Files:
${FILES}

Status: Completed Successfully"

echo -e "$EMAIL_BODY" | mail -s "Log Rotation Report" "$EMAIL"
