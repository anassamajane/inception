NAME = inception

all:
	mkdir -p /home/anaamaja/data/mariadb
	mkdir -p /home/anaamaja/data/wordpress
	docker compose -f srcs/docker-compose.yml up --build -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	rm -rf /home/anaamaja/data/mariadb
	rm -rf /home/anaamaja/data/wordpress

re: fclean all

.PHONY: all down clean fclean re
