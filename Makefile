# Illuminati Database Management System
#
# MySQL runs in a rootless podman container, so nothing has to be installed on
# the host and no sudo is required. Every target is idempotent.

CONTAINER ?= illuminati-mysql
VOLUME    ?= illuminati-data
IMAGE     ?= docker.io/library/mysql:8.4
DB        ?= Illuminati
ROOT_PW   ?= mysql
PORT      ?= 3306

MYSQL = podman exec -i -e MYSQL_PWD=$(ROOT_PW) $(CONTAINER) mysql -uroot

.PHONY: help db-up db-down db-load db-reset db-shell db-verify run clean

help:
	@echo "db-up      start the MySQL container (creates it on first run)"
	@echo "db-load    create the database, then load schema + seed"
	@echo "db-reset   reload schema + seed, discarding all local changes"
	@echo "db-verify  print table and row counts"
	@echo "db-shell   open a mysql prompt against $(DB)"
	@echo "db-down    stop and remove the container (data survives in the volume)"
	@echo "clean      db-down plus delete the volume -- destroys all data"
	@echo "run        launch the CLI application"

db-up:
	@podman volume inspect $(VOLUME) >/dev/null 2>&1 || podman volume create $(VOLUME) >/dev/null
	@if podman container exists $(CONTAINER); then \
		podman start $(CONTAINER) >/dev/null; \
	else \
		podman run -d --name $(CONTAINER) \
			-e MYSQL_ROOT_PASSWORD=$(ROOT_PW) \
			-p $(PORT):3306 \
			-v $(VOLUME):/var/lib/mysql \
			$(IMAGE) >/dev/null; \
	fi
	@printf 'waiting for mysql'
	@for i in $$(seq 1 60); do \
		if podman exec -e MYSQL_PWD=$(ROOT_PW) $(CONTAINER) mysqladmin -uroot ping >/dev/null 2>&1; then \
			echo ' ready'; exit 0; \
		fi; \
		printf '.'; sleep 2; \
	done; \
	echo ' TIMED OUT'; podman logs --tail 20 $(CONTAINER); exit 1

# schema.sql drops every table first, so this doubles as the reset path.
db-load: db-up
	@$(MYSQL) -e "CREATE DATABASE IF NOT EXISTS $(DB)"
	@$(MYSQL) $(DB) < sql/schema.sql
	@$(MYSQL) $(DB) < sql/seed.sql
	@echo "loaded schema + seed into $(DB)"

db-reset: db-load

db-verify: db-up
	@$(MYSQL) -N -B -e "SELECT CONCAT('tables: ', COUNT(*)) \
		FROM information_schema.tables \
		WHERE table_schema='$(DB)' AND table_type='BASE TABLE';"
	@$(MYSQL) -N -B -e "SELECT CONCAT('foreign keys: ', COUNT(*)) \
		FROM information_schema.referential_constraints \
		WHERE constraint_schema='$(DB)';"
	@$(MYSQL) -N -B $(DB) -e "SELECT CONCAT('rows: ', SUM(c)) FROM ( \
		SELECT COUNT(*) c FROM Artifacts_And_Treasures \
		UNION ALL SELECT COUNT(*) FROM Curators \
		UNION ALL SELECT COUNT(*) FROM Faction_Meetings \
		UNION ALL SELECT COUNT(*) FROM Faction_Members \
		UNION ALL SELECT COUNT(*) FROM Factions \
		UNION ALL SELECT COUNT(*) FROM Guards \
		UNION ALL SELECT COUNT(*) FROM Individuals \
		UNION ALL SELECT COUNT(*) FROM Key_Illuminati_Members \
		UNION ALL SELECT COUNT(*) FROM Orchestrates \
		UNION ALL SELECT COUNT(*) FROM Organizations \
		UNION ALL SELECT COUNT(*) FROM Organizations_Under_Control \
		UNION ALL SELECT COUNT(*) FROM Perform_Rituals \
		UNION ALL SELECT COUNT(*) FROM Powers \
		UNION ALL SELECT COUNT(*) FROM Sacred_Timeline_Events \
		UNION ALL SELECT COUNT(*) FROM Sanctum_Sanctorum \
		UNION ALL SELECT COUNT(*) FROM Secret_Knowledge_Archives \
		UNION ALL SELECT COUNT(*) FROM Surveillance \
		UNION ALL SELECT COUNT(*) FROM Surveys) t;"

db-shell: db-up
	@podman exec -it -e MYSQL_PWD=$(ROOT_PW) $(CONTAINER) mysql -uroot $(DB)

db-down:
	-@podman stop $(CONTAINER) >/dev/null 2>&1 || true
	-@podman rm $(CONTAINER) >/dev/null 2>&1 || true
	@echo "container removed; volume $(VOLUME) still holds the data"

clean: db-down
	-@podman volume rm $(VOLUME) >/dev/null 2>&1 || true
	@echo "volume $(VOLUME) deleted"

run:
	@uv run --with pymysql --with python-dateutil --with cryptography script.py
