echo ""
docker-compose exec kanepon apachectl -v
echo ""
docker-compose exec kanepon php -v
echo ""
docker-compose exec kanepon-db mysql --version
echo ""
docker-compose exec prx nginx -v
echo ""

