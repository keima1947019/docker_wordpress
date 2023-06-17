echo "Installing WP-CLI... Requires PHP 5.6 or higher..."
docker-compose exec kanepon curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
docker-compose exec kanepon chmod +x /usr/local/bin/wp
