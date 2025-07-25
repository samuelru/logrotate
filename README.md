# Docker Logrotate

A Docker image that performs log rotation for other containers running in the same Docker Swarm environment.

## Overview

This container runs logrotate to manage log files from other containers in your Docker Swarm. It helps prevent log files from growing too large and consuming all available disk space. The container is designed to be lightweight and configurable through environment variables.

## Features

- Rotates log files from other containers in the same Docker Swarm
- Configurable rotation interval (daily, weekly, monthly, yearly)
- Configurable size-based rotation
- Configurable number of backup copies to keep
- Timezone support
- Automatic compression of rotated logs

## Usage

### Environment Variables

All environment variables are optional and have default values:

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `LOGS_PATH` | Path to log files to rotate | `/logs/*.log` | Any valid path pattern |
| `TRIGGER_INTERVAL` | How often to rotate logs | `daily` | `hourly`, `daily`, `weekly`, `monthly`, `yearly` |
| `MAX_SIZE` | Rotate if log file size reaches this threshold | `NONE` | `NONE` or size (e.g., `1K`, `10M`, `1G`) |
| `MAX_BACKUPS` | Number of backup copies to keep | `365` | Any positive integer |
| `TZ` | Timezone | `UTC` | Any valid timezone (e.g., `Europe/Berlin`) |

### Docker Compose Example

```yaml
version: '3.8'

services:
  # Example service that generates logs
  traefik:
    image: traefik:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - logs:/logs  # folder containing access.log file
    ports:
      - "80:80"
      - "443:443"
    command:
      - "--accesslog=true"
      - "--accesslog.filepath=/logs/access.log"
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s

  # Logrotate service
  logrotate:
    image: samuelru/logrotate:1.0
    volumes:
      - logs:/logs
    environment:
      TZ: "Europe/Berlin"
      LOGS_PATH: "/logs/*.log"
      TRIGGER_INTERVAL: daily
      MAX_SIZE: NONE
      MAX_BACKUPS: 365
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s

volumes:
  logs:
    driver: local
```

### Deployment

To deploy the stack to a Docker Swarm:

```bash
docker stack deploy -c docker-compose.yml mystack
```

## Common Configurations

### Daily Rotation with Size Limit

```yaml
logrotate:
  image: samuelru/logrotate:1.0
  volumes:
    - logs:/logs
  environment:
    TRIGGER_INTERVAL: daily
    MAX_SIZE: 100M
    MAX_BACKUPS: 30
```

### Weekly Rotation

```yaml
logrotate:
  image: samuelru/logrotate:1.0
  volumes:
    - logs:/logs
  environment:
    TRIGGER_INTERVAL: weekly
    MAX_BACKUPS: 52
```

### Rotating Specific Log Files

```yaml
logrotate:
  image: samuelru/logrotate:1.0
  volumes:
    - logs:/logs
  environment:
    LOGS_PATH: "/logs/app-*.log"
```

## Building the Image

To build the Docker image locally:

```bash
docker build -t samuelru/logrotate:1.0 .
```

## Troubleshooting

### Logs Not Rotating

1. Check that the log files match the pattern specified in `LOGS_PATH`
2. Verify that the container has proper permissions to access the log files
3. Check the container logs for any errors:
   ```bash
   docker service logs mystack_logrotate
   ```

### Container Exiting Unexpectedly

1. Check that the cron daemon is running properly
2. Verify that the logrotate configuration is valid
3. Check system resources (memory, disk space)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Third-Party Components

This project uses the following third-party components:

- [Alpine Linux](https://alpinelinux.org/) - Licensed under [GNU General Public License](https://www.gnu.org/licenses/gpl-3.0.en.html)
- [logrotate](https://github.com/logrotate/logrotate) - Licensed under [GNU General Public License v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
- [tzdata](https://www.iana.org/time-zones) - Public Domain
- [bash](https://www.gnu.org/software/bash/) - Licensed under [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html)
- [coreutils](https://www.gnu.org/software/coreutils/) - Licensed under [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html)
- [findutils](https://www.gnu.org/software/findutils/) - Licensed under [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html)
- [grep](https://www.gnu.org/software/grep/) - Licensed under [GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.en.html)
- [Traefik](https://traefik.io/) (in example configuration) - Licensed under [MIT License](https://github.com/traefik/traefik/blob/master/LICENSE.md)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

By contributing to this project, you agree that your contributions will be licensed under the project's MIT License.