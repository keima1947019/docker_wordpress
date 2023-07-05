WPCON="<name of wordpress container>"
docker exec -i $WPCON wp core version --allow-root --path=/var/www/html --color
