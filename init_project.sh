#!/bin/bash

ROOT_PATH="$(pwd)"

# CREATING SOURCE CODE FOLDER
while true; do
    read -p "Source code folder name [code]: " SOURCE_CODE_FOLDER_NAME

    SOURCE_CODE_FOLDER_NAME=$(echo "$SOURCE_CODE_FOLDER_NAME" | sed 's/^[./]*//')

    if [ -z "$SOURCE_CODE_FOLDER_NAME" ]; then
        SOURCE_CODE_FOLDER_NAME="code"
    fi

    if [ -d "$SOURCE_CODE_FOLDER_NAME" ]; then
        echo "Folder already exists. Please enter another name: "
    else
        mkdir "$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME"
        break
    fi
done

# PROJECT SETTINGS
LARADOCK_FOLDER_NAME="laradock"
APP_CODE_PATH_HOST="../$SOURCE_CODE_FOLDER_NAME"
DATA_PATH_HOST="../data"

read -p "MySQL DB name [laravel]: " MYSQL_DATABASE
if [ -z "$MYSQL_DATABASE" ]; then
    MYSQL_DATABASE="laravel"
fi
read -p "MySQL user [laravel]: " MYSQL_USER
if [ -z "$MYSQL_USER" ]; then
    MYSQL_USER="laravel"
fi
read -p "MySQL password [laravel]: " MYSQL_PASSWORD
if [ -z "$MYSQL_PASSWORD" ]; then
    MYSQL_PASSWORD="laravel"
fi
read -p "MySQL root password [laravel]: " MYSQL_ROOT_PASSWORD
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_ROOT_PASSWORD="laravel"
fi

# LARADOCK
LARADOCK_PATH="$ROOT_PATH/$LARADOCK_FOLDER_NAME"
git clone https://github.com/laradock/laradock.git

cp "$LARADOCK_PATH/.env.example" "$ROOT_PATH/.env"
ln -s "$ROOT_PATH/.env" "$LARADOCK_PATH/.env"

# UPDATING DEFAULT ENVIRONMENT
sed -i "s|^APP_CODE_PATH_HOST=.*|APP_CODE_PATH_HOST=$APP_CODE_PATH_HOST|" "$ROOT_PATH/.env"
sed -i "s|^DATA_PATH_HOST=.*|DATA_PATH_HOST=$DATA_PATH_HOST|" "$ROOT_PATH/.env"
sed -i "s|^MYSQL_DATABASE=.*|MYSQL_DATABASE=$MYSQL_DATABASE|" "$ROOT_PATH/.env"
sed -i "s|^MYSQL_USER=.*|MYSQL_USER=$MYSQL_USER|" "$ROOT_PATH/.env"
sed -i "s|^MYSQL_PASSWORD=.*|MYSQL_PASSWORD=$MYSQL_PASSWORD|" "$ROOT_PATH/.env"
sed -i "s|^MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD|" "$ROOT_PATH/.env"

sed -i "s|# listen |listen |" "$LARADOCK_PATH/nginx/sites/default.conf"
sed -i "s|# ssl_certificate |ssl_certificate |" "$LARADOCK_PATH/nginx/sites/default.conf"
sed -i "s|# ssl_certificate_key |ssl_certificate_key |" "$LARADOCK_PATH/nginx/sites/default.conf"

cd $ROOT_PATH
env_file="$ROOT_PATH/.env"
if [ -e $env_file ]; then
  APP_CODE_PATH_HOST=$(grep "^APP_CODE_PATH_HOST=" "$env_file" | cut -d'=' -f2)
  APP_CODE_PATH_HOST=$(echo "$APP_CODE_PATH_HOST" | sed 's/^[./]*//')

  LARADOCK_FOLDER_NAME="$ROOT_PATH/laradock"
  if [ ! -z "$LARADOCK_FOLDER_NAME" ] && [ -d "$LARADOCK_FOLDER_NAME/.git" ]; then
    read -p "confirm you want to remove folder $LARADOCK_FOLDER_NAME/.git (y)/n: " user_input
    if [ -z "$user_input" ] || [ "$user_input" == "y" ]; then
      sudo rm -fr "$LARADOCK_FOLDER_NAME/.git"
    fi
  fi

  touch "$ROOT_PATH/.gitignore"
  echo "/.idea" > "$ROOT_PATH/.gitignore"
  echo "/data" >> "$ROOT_PATH/.gitignore"
fi

touch "$ROOT_PATH/commands.txt"
echo "cd laradock" >> "$ROOT_PATH/commands.txt"
echo "sudo docker-compose up -d nginx php-fpm mysql" >> "$ROOT_PATH/commands.txt"
echo "sudo docker-compose exec -it workspace bash" >> "$ROOT_PATH/commands.txt"
echo "composer create-project laravel/laravel ." >> "$ROOT_PATH/commands.txt"
echo "exit" >> "$ROOT_PATH/commands.txt"
echo "sed -i \"s|^DB_HOST=.*|DB_HOST=mysql # mysql container name|\" \"$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env\""  >> "$ROOT_PATH/commands.txt"
echo "sed -i \"s|^DB_DATABASE=.*|DB_DATABASE=$MYSQL_DATABASE|\" \"$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env\""  >> "$ROOT_PATH/commands.txt"
echo "sed -i \"s|^DB_USERNAME=.*|DB_USERNAME=$MYSQL_USER|\" \"$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env\""  >> "$ROOT_PATH/commands.txt"
echo "sed -i \"s|^DB_PASSWORD=.*|DB_PASSWORD=$MYSQL_PASSWORD|\" \"$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env\""  >> "$ROOT_PATH/commands.txt"
echo "sudo docker-compose exec -it workspace bash" >> "$ROOT_PATH/commands.txt"
echo "php artisan migrate"  >> "$ROOT_PATH/commands.txt"
echo "exit" >> "$ROOT_PATH/commands.txt"
echo "cd .." >> "$ROOT_PATH/commands.txt"
echo "sudo chown $USER:$USER ./$SOURCE_CODE_FOLDER_NAME -R && sudo chmod g+rwx ./$SOURCE_CODE_FOLDER_NAME -R" >> "$ROOT_PATH/commands.txt"

echo "# все команды внутри докера запускать внутри workspace:" >> "$ROOT_PATH/commands.txt"
echo "cd /home/dev/Projects/chatgpt-api/laradock && sudo docker-compose exec -it workspace bash && cd .." >> "$ROOT_PATH/commands.txt"
echo "# запуск контейнеров" >> "$ROOT_PATH/commands.txt"
echo "cd /home/dev/Projects/chatgpt-api/laradock && sudo docker-compose up -d nginx php-fpm mysql && cd .." >> "$ROOT_PATH/commands.txt"
echo "# остановка контейнеров" >> "$ROOT_PATH/commands.txt"
echo "cd /home/dev/Projects/chatgpt-api/laradock && sudo docker-compose down && cd .." >> "$ROOT_PATH/commands.txt"

echo "Please run all commands from file commands.txt to finish installing laravel project."
echo "And then you can open site: https://localhost"