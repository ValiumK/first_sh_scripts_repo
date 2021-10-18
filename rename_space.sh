#!/bin/bash

# Замена пробелов на андерскор(_) в имени файлов

# Сколько файлов переименованно
num=0

# Перебор файлов текущем каталоге
for filename in *
do
 # Фильтруем имена с помощью grep
 # Если есть пробел, то последняя операция
 # завершается 0
    echo "$filename" | grep -q " "
    if [ $? -eq 0 ]
    then
# Если код завершения 0, переименовываем
      fname=$filename
      n='echo $fname | sed -e "s/ /_/d"'
      let "num += 1"
      mv "$fname" "$n"
    fi
done

echo "Переименованно файлов: $num"

exit 0