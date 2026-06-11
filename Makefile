# dbplayground — lifecycle and convenience interface.
# Copy .env.example -> .env with `make init`, then `make up`.

COMPOSE := docker compose

# Load .env so targets honour customised ports/credentials (silent if absent).
-include .env
export

# Derive the LDAP base DN from LDAP_DOMAIN (example.org -> dc=example,dc=org).
comma := ,
LDAP_BASE_DN := dc=$(subst .,$(comma)dc=,$(LDAP_DOMAIN))

.PHONY: help init up up-all down reset ps logs psql mysql maria click ldap-search redis valkey

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

init: ## Create .env from .env.example if missing
	@test -f .env && echo ".env already exists" || (cp .env.example .env && echo "created .env")

up: ## Start default engines (pg, mysql, mariadb, clickhouse, redis, valkey, memcached) and wait for healthy
	@test -f .env || { echo "No .env found - run 'make init' first."; exit 1; }
	$(COMPOSE) up -d --wait
	$(COMPOSE) run --rm redis-seed
	$(COMPOSE) run --rm valkey-seed

up-all: ## Start default engines + OpenLDAP (ldap profile)
	@test -f .env || { echo "No .env found - run 'make init' first."; exit 1; }
	$(COMPOSE) --profile ldap up -d --wait
	$(COMPOSE) run --rm redis-seed
	$(COMPOSE) run --rm valkey-seed

down: ## Stop and remove containers (keep data volumes)
	$(COMPOSE) --profile ldap down

reset: ## Stop and remove containers AND volumes (forces reseed next up)
	$(COMPOSE) --profile ldap down -v

ps: ## Show service status
	$(COMPOSE) ps

logs: ## Follow logs for all services
	$(COMPOSE) logs -f

psql: ## Open a psql shell in the Postgres container
	$(COMPOSE) exec postgres psql -U $(DB_USER) -d $(DB_NAME)

mysql: ## Open a mysql shell in the MySQL container
	$(COMPOSE) exec mysql mysql -u$(DB_USER) -p$(DB_PASSWORD) $(DB_NAME)

maria: ## Open a mariadb shell in the MariaDB container
	$(COMPOSE) exec mariadb mariadb -u$(DB_USER) -p$(DB_PASSWORD) $(DB_NAME)

click: ## Open a clickhouse-client shell
	$(COMPOSE) exec clickhouse clickhouse-client -d $(CLICKHOUSE_DB)

ldap-search: ## Run a sample ldapsearch against the seeded directory
	$(COMPOSE) exec openldap ldapsearch -x -H ldap://localhost \
		-b "$(LDAP_BASE_DN)" -D "cn=admin,$(LDAP_BASE_DN)" -w $(LDAP_ADMIN_PASSWORD) "(objectClass=*)"

redis: ## Open a redis-cli shell in the Redis container
	$(COMPOSE) exec redis redis-cli

valkey: ## Open a valkey-cli shell in the Valkey container
	$(COMPOSE) exec valkey valkey-cli
