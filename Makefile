# MT4 Receiver Makefile

.PHONY: help start stop restart test health backup restore migrate clean logs test-supabase

# Default target
help:
	@echo "🚀 MT4 Receiver Commands:"
	@echo ""
	@echo "  make start     - Start the service"
	@echo "  make stop      - Stop the service"
	@echo "  make restart   - Restart the service"
	@echo "  make test      - Run API tests"
	@echo "  make health    - Check system health"
	@echo "  make backup    - Backup database"
	@echo "  make restore   - Restore database"
	@echo "  make migrate   - Migrate database schema"
	@echo "  make logs      - View service logs"
	@echo "  make clean     - Clean up containers and images"
	@echo "  make test-supabase - Test Supabase connection"
	@echo ""

# Service management
start:
	@./scripts/start.sh

stop:
	@./scripts/stop.sh

restart: stop start

# Testing and monitoring
test:
	@./scripts/test.sh

health:
	@./scripts/health-check.sh

test-supabase:
	@./scripts/test-supabase.sh

logs:
	@docker-compose logs -f

# Database management
backup:
	@./scripts/backup.sh

restore:
	@./scripts/restore.sh

migrate:
	@./scripts/migrate-db.sh

# Cleanup
clean:
	@echo "🧹 Cleaning up Docker resources..."
	@docker-compose down --rmi all --volumes --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed!"