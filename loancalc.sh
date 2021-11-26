#!/bin/bash
# loancalc -- По заданной сумме кредита, процентной ставке
# и продолжительности (в годах), вычисляет суммы платежей
# Формула: M = P * ( J / (1 - (1 + J) ^ -N)),
# где P = сумма кредита, J = месячная процентная ставка, N = протяженность(месяцев).
# Обычно пользователи вводят P, I (годовая процентная ставка) и L (протяженность
# в годах).

. library.sh # Подключить библиотечный сценарий.
if [ $# -ne 3 ] ; then
echo "Usage: $0 principal interest loan-duration-years" >&2
exit 1
fi

P=$1 I=$2 L=$3
J="$(scriptbc -p 8 $I / \( 12 \* 100 \) )"
N="$(( $L * 12 ))"
M="$(scriptbc -p 8 $P \* \( $J / \(1 - \(1 + $J\) \^ -$N\) \) )"

# Выполнить необходимые преобразования значений:
dollars="$(echo $M | cut -d. -f1)"
cents="$(echo $M | cut -d. -f2 | cut -c1-2)"

cat << EOF
A $L-year loan at $I% interest with a principal amount of $(nicenumber $P 1 )
results in a payment of \$$dollars.$cents each month for the duration of
the loan ($N payments).
EOF
exit 0
