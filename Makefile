build:
	docker compose build

up:
	docker compose up

down:
	docker compose down

db-create:
	docker compose exec app bin/rails db:create

db-migrate:
	docker compose exec app bin/rails db:migrate

assets:
	docker compose exec app bin/rails assets:precompile

clean:
	docker compose down --rmi all --volumes --remove-orphans
