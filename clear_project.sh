#!/bin/bash

ROOT_PATH="$(pwd)"

env_file="$ROOT_PATH/.env"

APP_CODE_PATH_HOST=$(grep "^APP_CODE_PATH_HOST=" "$env_file" | cut -d'=' -f2)
APP_CODE_PATH_HOST=$(echo "$APP_CODE_PATH_HOST" | sed 's/^[./]*//')

DATA_PATH_HOST=$(grep "^DATA_PATH_HOST=" "$env_file" | cut -d'=' -f2)
DATA_PATH_HOST=$(echo "DATA_PATH_HOST" | sed 's/^[./]*//')

LARADOCK_FOLDER_NAME="$ROOT_PATH/laradock_for_$APP_CODE_PATH_HOST"

docker-compose -f "$LARADOCK_FOLDER_NAME/docker-compose.yml" -f "$LARADOCK_FOLDER_NAME/docker-compose.custom.yml" down
echo "rm -rf $ROOT_PATH/$APP_CODE_PATH_HOST"
echo "rm -rf $ROOT_PATH/$DATA_PATH_HOST"
echo "rm -rf $LARADOCK_FOLDER_NAME"
echo "rm -rf $ROOT_PATH/.env"
echo "rm -rf $ROOT_PATH/docker-compose.custom.yml"
