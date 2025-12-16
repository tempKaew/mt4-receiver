# Deployment Guide

## Prerequisites

- Docker and Docker Compose
- Port 80 available on host machine

## Environment Setup

1. Copy environment template:

   ```bash
   cp api/.env.example api/.env
   ```

2. Configure Supabase credentials in `api/.env`:
   ```env
   PORT=3000
   DB_PATH=/app/db/data.sqlite
   SUPABASE_URL=https://your-project.supabase.co/rest/v1/your-table
   SUPABASE_TOKEN=your-service-role-key
   ```

## Deployment Steps

1. **Start the service:**

   ```bash
   make start
   # or
   ./scripts/start.sh
   ```

2. **Verify deployment:**

   ```bash
   make health
   # or
   ./scripts/health-check.sh
   ```

3. **Test API:**
   ```bash
   make test
   # or
   ./scripts/test.sh
   ```

## Service Management

- **Start:** `make start`
- **Stop:** `make stop`
- **Restart:** `make restart`
- **View logs:** `make logs`

## Database Management

- **Backup:** `make backup`
- **Restore:** `make restore`
- **Migrate:** `make migrate`

## Monitoring

- **Health check:** `make health`
- **API endpoint:** http://localhost/health
- **Logs:** `docker-compose logs -f`

## Troubleshooting

### Service won't start

- Check if port 80 is available
- Verify Docker is running
- Check logs: `make logs`

### Database issues

- Run migration: `make migrate`
- Check database file exists: `ls -la db/`
- Restore from backup: `make restore`

### API not responding

- Check container status: `docker-compose ps`
- Verify port mapping in docker-compose.yml
- Check firewall settings

## Production Considerations

1. **Security:**

   - Use strong Supabase tokens
   - Consider adding API authentication
   - Run behind reverse proxy (nginx)

2. **Monitoring:**

   - Set up log aggregation
   - Monitor disk space for database
   - Set up health check alerts

3. **Backup:**
   - Schedule regular database backups
   - Store backups off-site
   - Test restore procedures
