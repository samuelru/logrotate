<p align="center">
  <img src="https://raw.githubusercontent.com/samuelru/logrotate/main/.github/assets/logrotate-logo.png" alt="Docker Logrotate Logo" width="200" height="200">
</p>

# Docker Logrotate

A lightweight Docker image that performs log rotation for other containers running in the same Docker environment.

[![Build and Publish Docker Image](https://github.com/samuelru/logrotate/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/samuelru/logrotate/actions/workflows/docker-publish.yml)

## 📦 Available Tags

**Choose the right version for your environment:**

- **`latest`**: Latest stable build (updated monthly) - recommended for testing
- **`1.2.3`**: Specific version (from git tag v1.2.3) - recommended for production
- **`1.2`**: Latest patch version of a specific minor version - for controlled updates
- **`1`**: Latest minor.patch version of a specific major version - for automatic updates

Example: `samuelrunggaldier/logrotate:1.2.3`

## 🔄 Overview

This container runs logrotate to manage log files from other containers in your Docker environment. It helps prevent log files from growing too large and consuming all available disk space.

## ✨ Features

- Rotates log files from other containers
- Configurable rotation interval (hourly, daily, weekly, monthly, yearly)
- Configurable size-based rotation
- Configurable number of backup copies to keep
- Timezone support
- Automatic compression of rotated logs

## 🚀 Quick Start

```yaml
version: '3.8'

services:
  # Example service that generates logs
  app:
    image: your-app-image
    volumes:
      - logs:/logs

  # Logrotate service
  logrotate:
    image: samuelrunggaldier/logrotate:latest
    volumes:
      - logs:/logs
    environment:
      TZ: "Europe/Berlin"
      LOGS_PATH: "/logs/*.log"
      TRIGGER_INTERVAL: daily
      MAX_SIZE: 100M
      MAX_BACKUPS: 30
      DELAYCOMPRESS: "true"

volumes:
  logs:
    driver: local
```

### Run on Docker Desktop

Run locally with Docker Desktop using Docker Compose:

```bash
docker compose up -d
docker compose logs -f logrotate
```

Notes:

- The sample uses a named volume `logs` that works out-of-the-box on Docker Desktop.
- To use a bind mount instead, replace `logs:/logs` with `./logs:/logs` and ensure the folder is in a file-shared location (Docker Desktop Settings → Resources → File sharing).

## ⚙️ Environment Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `LOGS_PATH` | Path to log files to rotate | `/logs/*.log` | Any valid path pattern |
| `TRIGGER_INTERVAL` | How often to rotate logs | `daily` | `hourly`, `daily`, `weekly`, `monthly`, `yearly` |
| `MAX_SIZE` | Rotate if log file size reaches this threshold | `NONE` | `NONE` or size (e.g., `1K`, `10M`, `1G`) |
| `MAX_BACKUPS` | Number of backup copies to keep | `365` | Any positive integer |
| `DELAYCOMPRESS` | Delay compression of rotated logs until next rotation | `true` | `true`, `false` |
| `TZ` | Timezone | `UTC` | Any valid timezone (e.g., `Europe/Berlin`) |
| `SU_USER` | User for logrotate `su` directive (helps with bind mounts on Docker Desktop) | `root` | Any existing user inside container |
| `SU_GROUP` | Group for logrotate `su` directive | `root` | Any existing group inside container |

## 🔗 Links

- [GitHub Repository](https://github.com/samuelru/logrotate)
- [Full Documentation](https://github.com/samuelru/logrotate/blob/main/README.md)

## 📄 License

This project is licensed under the MIT License.