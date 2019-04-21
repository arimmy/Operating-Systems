#!/bin/bash

DIR="$1"

if [ $# -ne 2 ]; then
	echo bad param
	exit 1
fi

if [ ! -d "${DIR}" ]; then
	echo "${DIR}" is not a directory
	exit 2
fi


function participants {
for i in $(ls -l "${DIR}" | tail -n +2 | tr -s ' ' | cut -d ' ' -f 9); do
	echo ${i}
done
}


function outliers {
for i in $(ls -l "${DIR}" | tail -n +2 | awk '{print $9}'); do 
        cat "${DIR}"/"${i}" | awk '{print $9}' | sort | uniq >> temp
done

cat temp | sort | uniq > sorted 

for j in $(ls -l "${DIR}" | tail -n +2 | awk '{print $9}'); do
	sed -i "/^${j}$/d" ./sorted
done

cat sorted | sort | sed '/^\s*$/d'| uniq

rm temp
rm sorted
}


function unique {
for i in $(ls -l "${DIR}" | tail -n +2 | awk '{print $9}'); do
         cat "${DIR}"/"${i}" | awk '{print $9}' | sort | uniq >> temp
done

cat temp | sort | uniq -c > sorted

awk '$1 <= 3 {print $2}' sorted

rm temp
rm sorted
}

function cross_check {
for i in $(ls -l "${DIR}" | tail -n +2 | awk '{print $9}'); do
	cat "${DIR}"/"${i}" | egrep "QSO" > receivers

	while read line; do
		cmprec=$(echo ${line} | awk '{print $3}')
		cmpdate=$(echo ${line} | awk '{print $1}')
		cmphour=$(echo ${line} | awk '{print $2}')
		if [ -f "${DIR}"/"${cmprec}" ]; then
			if [ $(egrep "${i}" "${DIR}"/"${cmprec}" | egrep "${cmpdate}" | wc -l) -eq 0 ]; then
				awk -v r=$cmprec -v y=$cmpdate -v h=$cmphour '$4==y && $5==h && $9==r {print}' "${DIR}"/${i}
			elif [ $(egrep "${i}" "${DIR}"/"${cmprec}" | egrep "${cmphour}" | wc -l) -eq 0 ]; then
				awk -v r=$cmprec -v y=$cmpdate -v h=$cmphour '$4==y && $5==h && $9==r {print}' "${DIR}"/${i}
			fi
		else
			awk -v r=$cmprec -v y=$cmpdate -v h=$cmphour '$4==y && $5==h && $9==r {print}' "${DIR}"/${i}
		fi
	done < <(awk '{print $4,$5,$9}' receivers)
done
rm receivers
}

function bonus {
for i in $(ls -l "${DIR}" | tail -n +2 | awk '{print $9}'); do
         cat "${DIR}"/"${i}" | egrep "QSO" > receivers

	 while read line; do
                cmprec=$(echo ${line} | awk '{print $3}')
                cmpdate=$(echo ${line} | awk '{print $1}')
                cmphour=$(echo ${line} | awk '{print $2}')
			if [ -f "${DIR}"/"${cmprec}" ]; then
				for k in $(egrep "${i}" "${DIR}"/"${cmprec}"); do
					hour=$(echo ${k}| egrep -o "${cmphour}" | sed -r "s/([0-9]{2})([0-9]{2})/\1:\2/")
					epochhour=$(date -d "${hour}" +"%s")
                         		if [ $(echo ${k}| egrep -o "${cmpdate}"| date -d "${cmpdate}" +"%s") -ne  $(echo ${line}| egrep -o "${cmpdate}" | date -d "${cmpdate}" +"%s") ]; then
						awk -v r=$cmprec -v y=$cmpdate -v h=$cmphour '$4==y && $5==h && $9==r {print}' "${DIR}"/${i}
					elif [ ${epochhour} -gt $(( ${epochhour} + 180 )) ] || [ ${epochhour} -lt  $(( ${epochhour} - 180 )) ]; then 	
                               			awk -v r=$cmprec -v y=$cmpdate -v h=$cmphour '$4==y && $5==h && $9==r {print}' "${DIR}"/${i}
                         		fi

				done
 			else
                                  awk -v r=$cmprec -v y=$cmpdate -v h=$cmphour '$4==y && $5==h && $9==r {print}' "${DIR}"/${i}
                        fi

         done < <(awk '{print $4,$5,$9}' receivers)
done
rm receivers
}



if [ "$2" = participants ]; then
        participants
elif [ "$2" = outliers ]; then
	outliers
elif [ "$2" = unique ]; then
        unique
elif [ "$2" = cross_check ]; then
	cross_check
elif [ "$2" = bonus ]; then
	bonus
else 
	echo function "$2" does not exist
	exit 3
fi
