# Testing the Docker Logrotate Service

Since we can't directly test the Docker image in this environment, here's a guide on how to test the solution in a real Docker environment:

## Testing Steps

1. **Build the Docker image**:
   ```bash
   docker build -t samuelru/logrotate:1.0 .
   ```

2. **Create test log files**:
   Create a directory for logs and add some sample log files:
   ```bash
   mkdir -p test-logs
   echo "Test log entry 1" > test-logs/test.log
   echo "Test log entry 2" >> test-logs/test.log
   ```

3. **Run the container with test configuration**:
   ```bash
   docker run -d \
     --name logrotate-test \
     -v $(pwd)/test-logs:/logs \
     -e TRIGGER_INTERVAL=daily \
     -e MAX_SIZE=1K \
     -e MAX_BACKUPS=5 \
     samuelru/logrotate:1.0
   ```

4. **Check container logs**:
   ```bash
   docker logs logrotate-test
   ```
   You should see output indicating that the logrotate configuration was generated and the cron job was set up.

5. **Generate more log data**:
   ```bash
   for i in {1..1000}; do echo "Log entry $i" >> test-logs/test.log; done
   ```

6. **Check if rotation occurred**:
   ```bash
   ls -la test-logs/
   ```
   You should see rotated log files (e.g., test.log-20250725.gz).

7. **Test in a Docker Swarm environment**:
   ```bash
   # Initialize swarm if not already done
   docker swarm init

   # Deploy the stack
   docker stack deploy -c docker-compose.yml logrotate-test

   # Check services
   docker service ls
   docker service logs logrotate-test_logrotate
   ```

## Verification Checklist

- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] Logrotate configuration is generated correctly
- [ ] Cron job is set up correctly
- [ ] Log files are rotated according to the configuration
- [ ] Rotated logs are compressed
- [ ] Old rotated logs are deleted according to MAX_BACKUPS
- [ ] Service works correctly in Docker Swarm

## Potential Issues to Watch For

1. **Permission issues**: Ensure the container has proper permissions to access and modify log files.
2. **Cron not running**: Check if cron daemon is running properly inside the container.
3. **Logrotate configuration errors**: Verify the generated logrotate configuration is valid.
4. **Volume mounting issues**: Ensure volumes are mounted correctly.

## Performance Considerations

- Monitor the container's resource usage (CPU, memory) during log rotation operations
- For very large log files, consider adjusting the container's resource limits
- If rotating many log files, consider increasing the rotation interval or using size-based rotation