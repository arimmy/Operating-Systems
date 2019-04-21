#!/bin/bash

letters=$(echo {a..z} | sed 's/ //g')

for shift in {1..26}; do
	if [[ $(cat encrypted | tr a-z $(echo "${letters}" | sed -r "s/(.{"$shift"})(.*)/\2\1/g") | grep -o -c "fuehrer") -ge 1 ]]; then
		cat encrypted | tr a-z $(echo "${letters}" | sed -r "s/(.{"$shift"})(.*)/\2\1/g")
	fi 
done

printf '\n' 
