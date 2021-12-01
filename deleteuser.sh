#!/bin/bash

# deleteuser -- удаляет учетную запись.

homedir="/home"
pwfile="/etc/passwd"
shadow="/etc/shadow"
newpwfile="/etc/passwd.new"
newshadow="/etc/shadow.new"
suspend="$(which suspenduser)"
locker="/etc/passwd.lock"

if [ -z $1 ] ; then
  echo "Usage: $0 account" >&2
  exit 1
elif [ "$(whoami)" != "root" ] ; then
  echo "Error: you must be 'root' to run this command.">&2
  exit 1
fi

$suspend $1 # Заблокировать учетную запись на время выполнения работы.

uid="$(grep -E "^${1}:" $pwfile | cut -d: -f3)"

if [ -z $uid ] ; then
  echo "Error: no account $1 found in $pwfile" >&2
  exit 1
fi

# Удалить пользователя из файлов password и shadow.
grep -vE "^${1}:" $pwfile > $newpwfile
grep -vE "^${1}:" $shadow > $newshadow

lockcmd="$(which lockfile)" # Найти приложение lockfile.
if [ ! -z $lockcmd ] ; then # Использовать системную команду lockfile.
  eval $lockcmd -r 15 $locker
else                        # Не вышло, используем свой механизм.
  while [ -e $locker ] ; do
    echo "waiting for the password file" ; sleep 1
  done
  touch $locker             # Создать блокировку на основе файла.
fi

mv $newpwfile $pwfile
mv $newshadow $shadow

rm -f $locker # Снять блокировку.

chmod 644 $pwfile
chmod 400 $shadow

# Теперь удалить домашний каталог и вывести, что осталось.
rm -rf $homedir/$1

echo "Files still left to remove (if any):"
find / -uid $uid -print 2>/dev/null | sed 's/^/ /'

echo ""
echo "Account $1 (uid $uid) has been deleted, and their home directory "
echo "($homedir/$1) has been removed."
exit 0


