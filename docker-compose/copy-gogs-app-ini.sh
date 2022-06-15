#!/bin/bash

docker cp $(docker ps -aqf "name=docker-compose_gogs_1"):/data/gogs/conf/app.ini gogs-app.ini