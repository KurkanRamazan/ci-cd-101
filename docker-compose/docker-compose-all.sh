#! /bin/bash
export POSTGRES_USER=custom_user_root
export POSTGRES_PASSWORD=custom_user_root_password
export POSTGRES_DB=postgres
docker-compose up -d
read -t 3 -n 1