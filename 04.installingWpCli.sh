WPCON="<name of wordpress container>"
echo "Installing WP-CLI... Requires PHP 5.6 or higher..."
docker exec -i $WPCON curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker exec -i $WPCON chmod +x /usr/local/bin/wp
