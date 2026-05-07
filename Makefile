.PHONY: help up down logs update-models build restart

help: ## Muestra los comandos disponibles
	@echo "Opciones disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Inicia todos los contenedores del laboratorio en background
	docker compose up -d

down: ## Detiene y remueve los contenedores y redes
	docker compose down

build: ## Reconstruye las imágenes (útil si se cambió el código de backend o frontend)
	docker compose build

restart: ## Reinicia los contenedores
	docker compose down
	docker compose up -d

logs: ## Muestra los logs en tiempo real de todos los contenedores
	docker compose logs -f

update-models: ## Actualiza los modelos LLM en Ollama
	docker exec -it ollama ollama pull gemma3:4b
	docker exec -it ollama ollama pull gemma2:2b
