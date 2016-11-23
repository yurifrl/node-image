docker login --username=<user> --email=<mail>

run.sh: to run the current folder inside a node container
Makefile: build the work image and deploys it

# docker-compose.yml
```
version: '2'
services:
  web:
    image: yurifl/node
    command: npm run start
    ports:
      - 4200:4200
    volumes:
      - ./:/app
      - node_modules:/app/node_modules
      - bower_components:/app/bower_components

volumes:
  node_modules:
    external: true
  bower_components:
    external: true
```

# production.yml
```
version: '2'
services:
  web:
    image: demo
    ports:
      - 80:80
      - 443:443
    build:
      image: yurifl/web

```
