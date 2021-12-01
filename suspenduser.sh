#!/bin/bash

# suspenduser -- приостановка учетки юзера

homedir="/home" # Местонахождение домашних каталогов юзера
secs=20         # Пауза(сек) перед выводом юзера из системы

if [ -z $1 ] ; then
  echo "Usage: $0 account" >&2
  exit 1
elif [ "$(id -un)" != "root" ] ; then
  echo "Error. You must be 'root' to run this command." >&2
  exit 1
fi

echo "Please change the password for account $1 to something new."
passwd $1

#  Усли юзер в системе, выводим его принудительно.
if who|grep "$1" > /dev/null ; then

  for tty in $(who | grep $1 | awk '{print $2}'); do

    cat << "EOF" > /dev/$tty
*******************************************************************
СРОЧНОЕ СООБЩЕНИЕ ОТ АДМИНИСТРАТОРА:
Эта учетная запись блокируется, и вы будете выведены из системы
через 20 секунд. Пожалуйста, завершите все свои процессы и
выйдите из системы.
*******************************************************************
EOF
  done

  echo "(Warned $1, now sleeping $secs seconds)"

  sleep $secs

  jobs=$(ps -u $1 | cut -d\ -f1)

  kill -s HUP $jobs # Сигнал остановки процессам юзера.
  sleep 1           # 1 sec

  kill -s KILL $jobs > /dev/null 2>1 # Добить оставщиеся процессы.

  echo "$1 was logged in. Just logged time out."
fi

# Скрываем домашнюю папку юзера от посторонних.
chmod 000 $homedir/$1

echo "Account $1 has been suspended."

exit 0
