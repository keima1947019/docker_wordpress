WPCON="<name of wordpress container>"
DBCON="<name of mysql container>"
docker exec -i $WPCON apachectl -v
docker exec -i $WPCON php -v
docker exec -i $DBCON mysql --version
