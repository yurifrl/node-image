all:
	docker-compose build
	docker push yurifl/node:latest
