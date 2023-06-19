#!/bin/bash -u

DATE=`date +%Y%m%d_%H%M%S`

emptyCheckInputValues(){
  if [ -z "${str}" ]; then
    while [ -z "${str}" ]
    do
      echo "You did not input any words."
      echo -n "Type \"y\" or \"n\". -> "
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
      echo -n "Type \"y\" or \"n\". -> "
      read str
    done
  fi
}

confirm(){
  echo -n "Are you ready for backup ${CONNAME} ? [y|n]-> "
  read str
  if [ "${str}" = "y" ]; then
    :
  else
    while [ ! "${str}" = "y" ]
      do
        echo -n "Are you ready for backup ${CONNAME} ? [y|n]-> "
        read str
      done
  fi
}

# WordPress container

CONNAME=`docker ps | grep "wordpress" | awk '{print $(NF-n)}'`
echo "Is the name of wordpress container \"${CONNAME}\" ?"
echo -n "Type \"y\" or \"n\". -> "
read str
emptyCheckInputValues
setConName "wordpress"
confirm
echo "Backup ${CONNAME} ..."
docker run --rm --volumes-from ${CONNAME} -v $PWD:/backup busybox tar zcvf /backup/bkup_${CONNAME}.tar.gz.${DATE} /var/www/html > /dev/null
echo "wordpress backup has been finished!"

# MySQl container 

CONNAME=`docker ps | grep "mysql" | awk '{print $(NF-n)}'`
echo "Is the name of mysql container ${CONNAME} ?"
echo -n "Type \"y\" or \"n\". -> "
read str
emptyCheckInputValues
setConName "mysql"
DBPASS=`grep "MYSQL_ROOT_PASSWORD" docker-compose.yml | awk '{print $(NF-n)}'`
echo "Is MySQL db root password ${DBPASS} ?"
echo -n "Type \"y\" or \"n\". -> "
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
confirm
echo "Backup ${CONNAME} ..."
DUMPFILE="bkup_${CONNAME}.dump.${DATE}"
sh -c "docker exec -i ${CONNAME} mysqldump -uroot -p${DBPASS} --single-transaction --all-databases > ${DUMPFILE} " > /dev/null
echo "mysql backup has been finished!"