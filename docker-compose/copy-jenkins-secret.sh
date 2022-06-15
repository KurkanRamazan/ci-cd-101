#!/bin/bash

docker cp $(docker ps -aqf "name=docker-compose_jenkins_1"):/var/jenkins_home/secrets/initialAdminPassword jenkins-secret.txt