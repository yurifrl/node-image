all:
	docker build -t yurifl/work .
	docker build -t yurifl/node_modules - < Dockerfile.node_modules
	docker build -t yurifl/bower_components - < Dockerfile.bower_components
	docker push yurifl/work:latest
	docker push yurifl/node_modules:latest
	docker push yurifl/bower_components:latest

build:
	docker build -t yurifl/work .

build.node_modules:
	docker build -t yurifl/node_modules - < Dockerfile.node_modules

buid.bower_components:
	docker build -t yurifl/bower_components - < Dockerfile.bower_components

push.work:
	docker push yurifl/work:latest

push.node_modules:
	docker push yurifl/node_modules:latest

push.bower_components:
	docker push yurifl/bower_components:latest
