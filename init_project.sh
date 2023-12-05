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
        echo "Folder '$SOURCE_CODE_FOLDER_NAME' was successfully created."
        break
    fi
done

# PROJECT SETTINGS
LARADOCK_FOLDER_NAME="laradock_for_$SOURCE_CODE_FOLDER_NAME"
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
git clone https://github.com/laradock/laradock.git $LARADOCK_PATH

cp "$LARADOCK_PATH/.env.example" "$ROOT_PATH/.env"
ln -s "$ROOT_PATH/.env" "$LARADOCK_PATH/.env"

# UPDATING DEFAULT ENVIRONMENT
sed -i "s|^APP_CODE_PATH_HOST=.*|APP_CODE_PATH_HOST=$APP_CODE_PATH_HOST|" .env
sed -i "s|^DATA_PATH_HOST=.*|DATA_PATH_HOST=$DATA_PATH_HOST|" .env
sed -i "s|^MYSQL_DATABASE=.*|MYSQL_DATABASE=$MYSQL_DATABASE|" .env
sed -i "s|^MYSQL_USER=.*|MYSQL_USER=$MYSQL_USER|" .env
sed -i "s|^MYSQL_PASSWORD=.*|MYSQL_PASSWORD=$MYSQL_PASSWORD|" .env
sed -i "s|^MYSQL_ROOT_PASSWORD=.*|MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD|" .env

# CREATE CUSTOM docker-compose FILE
touch "$ROOT_PATH/docker-compose.custom.yml"
ln -s "$ROOT_PATH/docker-compose.custom.yml" "$LARADOCK_PATH/docker-compose.custom.yml"

sed -i "s|# listen |listen |" "$LARADOCK_PATH/nginx/sites/default.conf"
sed -i "s|# ssl_certificate |ssl_certificate |" "$LARADOCK_PATH/nginx/sites/default.conf"
sed -i "s|# ssl_certificate_key |ssl_certificate_key |" "$LARADOCK_PATH/nginx/sites/default.conf"

# START nginx php-fpm
docker-compose -f "$LARADOCK_PATH/docker-compose.yml" -f "$LARADOCK_PATH/docker-compose.custom.yml" up -d nginx php-fpm mysql

# INSTALL LARAVEL
cd $LARADOCK_PATH
docker-compose exec -it workspace composer create-project laravel/laravel .
cd $ROOT_PATH

sed -i "s|^DB_HOST=.*|DB_HOST=mysql # mysql container name|" "$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env"
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$MYSQL_DATABASE|" "$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env"
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$MYSQL_USER|" "$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env"
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$MYSQL_PASSWORD|" "$ROOT_PATH/$SOURCE_CODE_FOLDER_NAME/.env"

cd $LARADOCK_PATH
sleep 5
docker-compose exec -it workspace php artisan migrate
docker-compose exec -it workspace npm i
docker-compose exec -it workspace npm run build
sleep 3
cd $ROOT_PATH
sleep 2
echo "run these commands to fix logging permissions:"
echo "sudo chown \$USER:\$USER $ROOT_PATH/$SOURCE_CODE_FOLDER_NAME -R && sudo chmod g+rwx $ROOT_PATH/$SOURCE_CODE_FOLDER_NAME -R"
echo "sudo chown \$USER:\$USER $ROOT_PATH/.env -R && sudo chmod g+rwx $ROOT_PATH/.env -R"
echo "sudo chown \$USER:\$USER $ROOT_PATH/docker-compose.custom.yml -R && sudo chmod g+rwx $ROOT_PATH/docker-compose.custom.yml -R"
echo "and next you can open site:"
echo "https://localhost"


#git init
#git add ./.gitignore
#git commit -m ".gitignore added;" .gitignore
#git add ./docker-compose.custom.yml
#git commit -m "docker-compose.custom.yml;" ./docker-compose.custom.yml
#git add ./code
#git commit -m "empty laravel project created;" ./code

#docker-compose -f "/home/dev/Projects/chatgpt-api/laradock_for_code/docker-compose.yml" -f "/home/dev/Projects/chatgpt-api/docker-compose.custom.yml" up -d nginx php-fpm mysql
#docker-compose -f "/home/dev/Projects/chatgpt-api/laradock_for_code/docker-compose.yml" -f "/home/dev/Projects/chatgpt-api/docker-compose.custom.yml" down