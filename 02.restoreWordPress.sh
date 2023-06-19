#!/bin/bash

# function

emptyCheckInputValues(){
  if [ -z "${str}" ]; then
    while [ -z "${str}" ]
    do
      echo -n "You did not input any words. -> "
      read str
    done
  fi
}

getContainerName(){
  CONNAME=`docker ps | grep "$2" | awk '{print $(NF-n)}'`
  echo "$1 : ${CONNAME} ?"
  echo -n "Type \"y\" or \"n\". -> "
  read str
  emptyCheckInputValues
  if [ "${str}" = "y" -o "${str}" = "Y" ] ; then
    echo "$1 : ${CONNAME} !"
    :
  else
    docker ps | grep -e "NAMES" -e "$2"
    echo -n "$1 -> "
    read str
    emptyCheckInputValues
    CONNAME=${str}
    echo "$1 : \"${CONNAME}\" !"
  fi
}

getBkupFileName(){
  ls -alt | grep bkup_
  echo -n "$1 -> "
  read str
  emptyCheckInputValues
  BKUPFILE=${str}
  echo "$1 : ${BKUPFILE} ?"
  echo -n "Type \"y\" or \"n\". -> "
  read str
  emptyCheckInputValues
  if [ "${str}" = "y" -o "${str}" = "Y" ] ; then
    echo "$1 : ${BKUPFILE} !"
    :
  else
    while [ ! "${str}" = "y" -o ! "${str}" = "Y" ]
    do
      ls -alt | grep bkup_
      echo -n "Type $1 -> "
      read str
      emptyCheckInputValues
      BKUPFILE=${str}
      echo "$1 : \"${BKUPFILE}\" ?"
      echo -n "Type \"y\" or \"n\". -> "
      read str
    done
  fi
}

confirm(){
  echo -n "Are you ready for restoring ${CONNAME} ? [y|n]-> "
  read str
  if [ "${str}" = "y" ]; then
    :
  else
    while [ ! "${str}" = "y" ]
      do
        echo -n "Are you ready for restoring ${CONNAME} ? [y|n]-> "
        read str
      done
  fi
}

# wordpress

getContainerName "WP-container-name" "wordpress"
getBkupFileName "WP-bkup-file"
confirm
docker run --rm --volumes-from ${CONNAME} -v ${PWD}:/backup busybox tar zxvf /backup/${BKUPFILE} > /dev/null

# MySQL

getContainerName "MySQL-container-name" "mysql"
getBkupFileName "MySQL-dump-file"
grep -n -e "MYSQL_ROOT_PASSWORD" -e "container_name" docker-compose.yml
echo -n "Type DB PW -> "
read str
emptyCheckInputValues
DBPASS=${str}
echo "DB PW : ${DBPASS} ?"
echo -n "Type \"y\" or \"n\" -> "
read str
emptyCheckInputValues
if [ "${str}" = "y"  ] ; then
  echo "DB PW : ${DBPASS} !"
  :
else
  grep -n -e "MYSQL_ROOT_PASSWORD" -e "container_name" docker-compose.yml
  echo -n "Type DB PW -> "
  read str
  emptyCheckInputValues
  DBPASS=${str}
  echo "DB PW : \"${DBPASS}\" !"
fi
confirm
docker cp ${BKUPFILE} ${CONNAME}:/ > /dev/null
sh -c "docker exec -i ${CONNAME} mysql -uroot -p${DBPASS} < ${BKUPFILE} " > /dev/null