#!/bin/bash

wrn="Using a password on the command line interface can be insecure."



host='localhost'
dbname='ecs'

if test $# -lt 2; then
    echo "usage : ./<script> <update directory> <login> <host> <dbname>"
    exit 1
fi

dir=$1
login=$2
if test $# -gt 2; then
    host=$3
fi
if test $# -gt 3; then
    dbname=$4
fi

echo -n "Enter password: "
stty -echo
read password
stty echo
echo

#EST CE QUE LE DOSSIER :
# - est un dossier ? 
# - contient des scipts à exécuter ?


DB_v=$(echo "select max(idversion) from version;" | mysql -N -h $host -u $login -p$password $dbname 2>&1 | grep -v "$wrn")

#à supprimer avec les fonctions qui réalisent les commandes sql :
if test $? -ne 0 ; then
    exit 1
fi

L_v=$(ls $dir | grep ".*\.sql$" | sort -n | tail -n 1 | grep -o "^[0-9]*")


echo "Current version : $DB_v"
echo "Latest version available : $L_v"

if test $DB_v -eq $L_v; then
    echo "The database is already up-to-date. No change needed."
    exit 0
elif test $DB_v -gt $L_v; then
    echo "Error : The database has a more recent version than the local scripts. Exiting." >2
    exit 1
fi



#From here, we are going to update the database :
ex=0
for i in $(ls $dir | grep ".*\.sql$" | sort -n | grep '^[0-9]')
do
    if test $ex -eq 1; then
     echo "Executing script <$dir/$i>"
     cat "$dir/$i" | mysql -h $host -u $login -p$password $dbname 2>&1 | grep -v "$wrn"
       #si l exec a fonctionné :
       num=$(echo $i | grep -o "^[0-9]*")
       echo "INSERT INTO version VALUES($num);" | mysql -h $host -u $login -p$password $dbname 2>&1 | grep -v "$wrn"
       #sinon, sortir du programme
   elif test $(echo $i | grep -o "^[0-9]*") -eq $DB_v; then
       ex=1
   fi
done


exit 0;