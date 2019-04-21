#!/bin/bash

DST="$1"
SRC="$2"

if [ $# -ne 2 ]; then
        echo bad param
        exit 1
fi

if [ ! -d "${DST}" ]; then
        echo "${DIR}" is not a directory
        exit 2
fi

if [ ! -z "$(ls -A "${DIR}")" ]; then
	echo "${DIR}" is not empty
	exit 3
fi

if [ -z $(which wget) ]; then
	echo command wget does not exist
	exit 4
fi


wget -O ./contestants.html "${SRC}" 

cat contestants.html | egrep -o ">[0-9A-Z]+<" | sed 's/^.//' | sed 's/.$//' > temp

while read line; do
	wget "${SRC}"/"${line}" -P "${DST}"/
done < temp

rm temp
