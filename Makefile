NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_PATH = /home/anaamaja/data

all:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@$(COMPOSE) up --build -d

up:
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

clean:
	@$(COMPOSE) down -v
	@rm -rf $(DATA_PATH)

fclean: clean
	@docker system prune -af

re: fclean all

logs:
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

.PHONY: all up down clean fclean re logs ps