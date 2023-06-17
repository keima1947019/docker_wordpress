#!/bin/bash

echo -n "Type \"date-time strings\"  of backup file. (example: 20230616_090856) -> "
read str

WPBKUP="bkup_kanepon.tar.gz.${str}"
DBBKUP="bkup_kanepon-db.dump.${str}"
WPCON="kanepon"
DBCON="kanepon-db"
DBPASS="A3Q30sMC9O9AVHNH"

# Check WordPress backup file name.

echo "Is WordPress backup file ${WPBKUP} ?"
echo -n "If correct, type \"y\", or \"n\". -> "
read str
if [ "${str}" = "y"  ] ; then
  :
else
  ls -alt
  echo -n "Type WordPress backup file name. -> "
  read str
  WPBKUP=${str}
  echo "OK. WordPress backup file is set as \"${WPBKUP}\"."
fi

# Check MySQL dump file name.

echo "Is MySQL dump file ${DBBKUP} ?"
echo -n "If correct, type \"y\", or \"n\". -> "
read str
if [ "${str}" = "y"  ] ; then
  :
else
  ls -alt
  echo -n "Type MySQL dump file name. -> "
  read str
  DBBKUP=${str}
  echo "MySQL dump file was set as \"${DBBKUP}\"."
fi

# Check MySQL db root password.

echo "Is MySQL db root password ${DBPASS} ?"
echo -n "If correct, type \"y\", or \"n\". -> "
read str
if [ "${str}" = "y"  ] ; then
  :
else
  grep -n -e "MYSQL_ROOT_PASSWORD" -e "container_name" docker-compose.yml
  echo -n "Type MySQL db root password. -> "
  read str
  DBPASS=${str}
  echo "MySQL db root papssword was set as \"${DBPASS}\"."
fi

# Check WordPress container name.

echo "Is WordPress container name ${WPCON} ?"
echo -n "If correct, type \"y\", or \"n\". -> "
read str
if [ "${str}" = "y"  ] ; then
  :
else
  docker ps | grep -e "NAMES" -e "wordpress"
  echo -n "Type WordPress container name. -> "
  read str
  WPCON=${str}
  echo "WordPress container name was set as \"${DBPASS}\"."
fi

# Check MySQL container name.

echo "Is MySQL container name ${DBCON} ?"
echo -n "If correct, type \"y\", or \"n\". -> "
read str
if [ "${str}" = "y"  ] ; then
  :
else
  docker ps | grep -e "NAMES" -e "mysql"
  echo -n "Type mysql container name. -> "
  read str
  DBCON=${str}
  echo "MySQL container name was set as \"${DBCON}\"."
fi

# Execute restoring.

# WordPress
docker run --rm --volumes-from ${WPCON} -v ${PWD}:/backup busybox tar zxvf /backup/${WPBKUP} > /dev/null

# MySQL
docker cp ${DBBKUP} ${DBCON}:/ > /dev/null
sh -c "docker exec -i ${DBCON} mysql -uroot -p${DBPASS} < ${DBBKUP} " > /dev/null

