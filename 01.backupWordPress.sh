#!/bin/bash -u

DATE=`date +%Y%m%d_%H%M%S`

emptyCheckInputValues(){
  if [ -z "${str}" ]; then
    while [ -z "${str}" ]
    do
      echo "You did not input any words."
      echo -n "If correct, type y, or type anything but y. -> "
      read str
    done
  fi
}

setConName(){
  if [ ! "${str}" = "y" ]; then
    while [ ! "${str}" = "y" ]
    do
      docker ps | grep -e "NAMES" -e "$1"
      echo -n "Type the name of target $1 container. -> "
      read str
      CONNAME=${str}
      echo "Is the name of $1 container ${CONNAME} ?"
      echo -n "If correct, type y, or type anything but y. -> "
      read str
    done
  fi
}

# WordPress container name

WPCON=`docker ps | grep "wordpress" | awk '{print $(NF-n)}'`
echo "Is the name of wordpress container \"${WPCON}\" ?"
echo -n "If correct, type y, or type anything but y. -> "
read str
emptyCheckInputValues
setConName "wordpress" "WPCON"

echo "OK. I set the variable WPCON to the value of \"${WPCON}\"."

# MySQl container name

DBCON=`docker ps | grep "mysql" | awk '{print $(NF-n)}'`
echo "Is the name of mysql container ${DBCON} ?"
echo -n "If correct, type y, or type anything but y. -> "
read str
emptyCheckInputValues
setConName "mysql" "DBCON"

# MySQL db root password

DBPASS=`grep "MYSQL_ROOT_PASSWORD" docker-compose.yml | awk '{print $(NF-n)}'`
echo "Is MySQL db root password ${DBPASS} ?"
echo -n "If correct, type y, or type anything but y. -> "
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

# Backup execution

echo -n "Are you ready for backup? [y|n]-> "
read str
if [ "${str}" = "y" ]; then
  :
else
  while [ ! "${str}" = "y" ]
    do
      echo -n "Are you ready for backup? [y|n]-> "
      read str
    done
fi

docker run --rm --volumes-from $WPCON -v $PWD:/backup busybox tar zcvf /backup/bkup_${WPCON}.tar.gz.${DATE} /var/www/html > /dev/null
DUMPFILE="bkup_${DBCON}.dump.${DATE}"
sh -c "docker exec -i ${DBCON} mysqldump -uroot -p${DBPASS} --single-transaction --all-databases > ${DUMPFILE} " > /dev/null