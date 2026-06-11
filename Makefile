# dbplayground — lifecycle and convenience interface.
# Copy .env.example -> .env with `make init`, then `make up`.

COMPOSE := docker compose

.PHONY: help init up up-all down reset ps logs psql mysql maria click ldap-search

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

init: ## Create .env from .env.example if missing
	@test -f .env && echo ".env already exists" || (cp .env.example .env && echo "created .env")

up: ## Start default engines (pg, mysql, mariadb, clickhouse) and wait for healthy
	$(COMPOSE) up -d --wait

up-all: ## Start default engines + OpenLDAP (ldap profile)
	$(COMPOSE) --profile ldap up -d --wait

down: ## Stop and remove containers (keep data volumes)
	$(COMPOSE) --profile ldap down

reset: ## Stop and remove containers AND volumes (forces reseed next up)
	$(COMPOSE) --profile ldap down -v

ps: ## Show service status
	$(COMPOSE) ps

logs: ## Follow logs for all services
	$(COMPOSE) logs -f

psql: ## Open a psql shell in the Postgres container
	$(COMPOSE) exec postgres psql -U playground -d testdb

mysql: ## Open a mysql shell in the MySQL container
	$(COMPOSE) exec mysql mysql -uplayground -pplayground testdb

maria: ## Open a mariadb shell in the MariaDB container
	$(COMPOSE) exec mariadb mariadb -uplayground -pplayground testdb

click: ## Open a clickhouse-client shell
	$(COMPOSE) exec clickhouse clickhouse-client -d testdb

ldap-search: ## Run a sample ldapsearch against the seeded directory
	$(COMPOSE) exec openldap ldapsearch -x -H ldap://localhost \
		-b "dc=example,dc=org" -D "cn=admin,dc=example,dc=org" -w adminpw "(objectClass=*)"
