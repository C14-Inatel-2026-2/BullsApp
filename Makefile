.PHONY: run clean build-apk build-web get test format docker-build docker-up docker-down docker-logs docker-stop docker-rm docker-shell help

# Flutter Commands
run:
	flutter run

clean:
	flutter clean

build-apk:
	flutter build apk --release

build-web:
	flutter build web --release

get:
	flutter pub get

test:
	flutter test

format:
	dart format lib/

# Docker Commands
help:
	@echo "=== BullsApp Flutter Commands ==="
	@echo "make run         - Executar app em desenvolvimento"
	@echo "make clean       - Limpar build"
	@echo "make build-apk   - Build APK release"
	@echo "make build-web   - Build web release"
	@echo "make get         - Obter dependências"
	@echo "make test        - Rodar testes"
	@echo "make format      - Formatar código"
	@echo ""
	@echo "=== BullsApp Docker Commands ==="
	@echo "make docker-build    - Build a imagem Docker"
	@echo "make docker-up       - Iniciar o container com docker-compose"
	@echo "make docker-down     - Parar e remover o container"
	@echo "make docker-logs     - Ver logs do container"
	@echo "make docker-stop     - Parar o container"
	@echo "make docker-rm       - Remover container e imagem"
	@echo "make docker-shell    - Entrar no container (shell interativo)"

build:
	docker build -t bullsapp:latest .

up:
	docker-compose up --build

down:
	docker-compose down

logs:
	docker-compose logs -f bullsapp

stop:
	docker-compose stop

docker-rm:
	docker-compose down --rmi all

docker-shell:
	docker-compose exec bullsapp sh
