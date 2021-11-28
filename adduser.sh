#!/bin/bash

# adduser -- добавляет нового юзера в систему с домашним каталогом 
#  и конфигурацией по умолчанию 

pwfile="/etc/passwd"
shadowfile="/etc/shadow"
gfile="/etc/group"
hdir="/home"

if [ "$(id -un)" != "root" ] ; then
  echo "Error: You mist be root to run this command." >&2
  exit 1
fi

echo "Add new user account to $(hostname)"
/bin/echo -n "login: " ; read login

# Далее ограничиваем UID значением 300
uid="$(awk -F: '{ if (big < $3 && $3 < 300) big=$3 } END { print big + 1 }'\
        $pwfile)"
homedir=$hdir/$login

# Каждому юзеру своя группа
gid=$uid

/bin/echo -n "full name: " ; read fullname
/bin/echo -n "shell: " ; read shell

echo "Setting up account $login for $fullname..."

echo ${login}:x:${uid}:${gid}:${fullname}:${homedir}:$shell >> $pwfile
echo ${login}:*:11647:0:99999:7::: >> $shadowfile

echo "${login}:x:${gid}:$login" >> $gfile

mkdir $homedir

cp -R /etc/skel/.[a-zA-Z]* $homedir
chmod 755 $homedir
chown -R ${login}:${login} $homedir

# Установка начального пароля
exec passwd $login
