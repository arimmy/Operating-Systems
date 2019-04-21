#!/bin/bash

declare -A MORSE

while read line; do
	letter=$(echo $line | cut -d ' ' -f 1)
	code=$(echo $line | cut -d ' ' -f 2)
	MORSE[$code]=$letter
done < morse

printf '' > encrypted

read line < secret_message
 
for word in $line; do
	for element in ${!MORSE[@]}; do
		if [[ "${word}" == "${element}" ]]; then 
			printf  "${MORSE[$element]}" | tr A-Z a-z 
		fi	
	done 
done >> encrypted

printf '\n' >> encrypted
