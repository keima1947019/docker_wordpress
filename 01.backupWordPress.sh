#!/bin/bash -u

DATE=`date +%Y%m%d_%H%M%S`

# WordPress container name

WPCON=`docker ps | grep "wordpress" | awk '{print $(NF-n)}'`
echo "Is the name of wordpress container \"${WPCON}\" ?"
echo -n "If correct, type y, or n. -> "
read str
if [ "${str}" = "y" ]; then
  :
else
  docker ps | grep -e "NAMES" -e "wordpress"
  echo -n "Type the name of target wordpress container. -> "
  read str
  WPCON=${str}
fi
str="n"

# MySQl container name

DBCON=`docker ps | grep "mysql" | awk '{print $(NF-n)}'`
echo "Is the name of mysql container ${DBCON} ?"
echo -n "If correct, type y, or n. -> "
read str
if [ "${str}" = "y" ]; then
  :
else
  docker ps | grep -e "NAMES" -e "mysql"
  echo -n "Type the name of target mysql container. -> "
  read str
  WPCON=${str}
fi
str="n"

# MySQL db root password

DBPASS=`grep "MYSQL_ROOT_PASSWORD" docker-compose.yml | awk '{print $(NF-n)}'`
echo "Is MySQL db root password ${DBPASS} ?"
echo -n "If correct, type y, or n. -> "
read str
if [ "${str}" = "y" ]; then
  :
else
  grep -n -e "MYSQL_ROOT_PASSWORD"  -e "container_name" docker-compose.yml
  echo -n "Type MySQL DB root password. -> "
  read str
  DBPASS=${str}
  echo "MySQL db root papssword was set as ${DBPASS}."
fi
str="n"

# Backup execution

docker run --rm --volumes-from $WPCON -v $PWD:/backup busybox tar zcvf /backup/bkup_${WPCON}.tar.gz.${DATE} /var/www/html > /dev/null
DUMPFILE="bkup_${DBCON}.dump.${DATE}"
sh -c "docker exec -i ${DBCON} mysqldump -uroot -p${DBPASS} --single-transaction --all-databases > ${DUMPFILE} " > /dev/null
