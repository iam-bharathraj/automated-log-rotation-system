# automated-log-rotation-system
This project automates log rotation using Bash scripting by identifying large files, compressing them, and moving them to an archive directory.

## Features
- Compresses files larger than 10MB using gzip
- Moves compressed files to an archive directory
- Monitors disk usage before cleanup execution
- Generates email-based execution reports
- Supports cron scheduling for automation

Note: Replace EMAIL variable with your own email address and configure SMTP locally before execution.
