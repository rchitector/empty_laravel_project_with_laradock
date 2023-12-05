#!/bin/bash

ROOT_PATH="$(pwd)"

if [ ! -z "$ROOT_PATH" ]; then

  ENV_FILE="$ROOT_PATH/.env"

  if [ -e $ENV_FILE ]; then
    APP_CODE_PATH_HOST=$(grep "^APP_CODE_PATH_HOST=" "$ENV_FILE" | cut -d'=' -f2)
    APP_CODE_PATH_HOST=$(echo "$APP_CODE_PATH_HOST" | sed 's/^[./]*//')

    if [ ! -z "$APP_CODE_PATH_HOST" ]; then
      LARADOCK_FOLDER_NAME="$ROOT_PATH/laradock"
      cd $LARADOCK_FOLDER_NAME
      sudo docker-compose down
      cd $ROOT_PATH

      read -p "confirm you want to remove folder $ROOT_PATH/$APP_CODE_PATH_HOST (y)/n: " user_input
      if [ -z "$user_input" ] || [ "$user_input" == "y" ]; then
        sudo rm -rf $ROOT_PATH/$APP_CODE_PATH_HOST
      fi

      read -p "confirm you want to remove folder $LARADOCK_FOLDER_NAME (y)/n: " user_input
      if [ -z "$user_input" ] || [ "$user_input" == "y" ]; then
        sudo rm -rf $LARADOCK_FOLDER_NAME
      fi
    fi

    DATA_PATH_HOST=$(grep "^DATA_PATH_HOST=" "$ENV_FILE" | cut -d'=' -f2)
    DATA_PATH_HOST=$(echo $DATA_PATH_HOST | sed 's/^[./]*//')
    if [ ! -z "$DATA_PATH_HOST" ]; then
      read -p "confirm you want to remove folder $ROOT_PATH/$DATA_PATH_HOST (y)/n: " user_input
      if [ -z "$user_input" ] || [ "$user_input" == "y" ]; then
        sudo rm -rf $ROOT_PATH/$DATA_PATH_HOST
      fi
    fi
  fi

  FILE_NAME="$ROOT_PATH/.env"
  if [ -e $FILE_NAME ]; then
    read -p "confirm you want to remove file $FILE_NAME (y)/n: " confirm
    if [ -z "$confirm" ] || [ "$confirm" == "y" ]; then
      sudo rm $FILE_NAME
    fi
  fi

  FILE_NAME="$ROOT_PATH/.gitignore"
  if [ -e $FILE_NAME ]; then
    read -p "confirm you want to remove file $FILE_NAME (y)/n: " confirm
    if [ -z "$confirm" ] || [ "$confirm" == "y" ]; then
      sudo rm $FILE_NAME
    fi
  fi

  FILE_NAME="$ROOT_PATH/commands.txt"
  if [ -e $FILE_NAME ]; then
    read -p "confirm you want to remove file $FILE_NAME (y)/n: " confirm
    if [ -z "$confirm" ] || [ "$confirm" == "y" ]; then
      sudo rm $FILE_NAME
    fi
  fi
fi