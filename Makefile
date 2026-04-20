# ⚠️  IMPORTANT: Replace 'yourlogin' with your actual 42 login everywhere in this file
#              AND in srcs/.env AND in srcs/docker-compose.yml

DATA_PATH = /home/$(USER)/data

all: setup
	@echo "Building and starting all containers..."
	cd srcs && docker compose up -d --build

# Creates the host directories that Docker named volumes will bind to
# ⚠️  These MUST exist before running docker compose up
setup:
	@echo "Creating data directories at $(DATA_PATH)..."
	mkdir -p $(DATA_PATH)/db
	mkdir -p $(DATA_PATH)/wordpress

down:
	@echo "Stopping containers..."
	cd srcs && docker compose down

# Stops containers, removes volumes and images — full wipe
clean: down
	cd srcs && docker compose down -v --rmi all 2>/dev/null || true
	sudo rm -rf $(DATA_PATH)
	@echo "Cleaned."

re: clean all

# Useful for debugging
logs:
	cd srcs && docker compose logs -f

ps:
	cd srcs && docker compose ps

.PHONY: all setup down clean re logs ps
