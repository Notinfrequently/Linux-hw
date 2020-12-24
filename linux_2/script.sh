#!/bin/bash
#exit if any command fails
set -e

LOCKFILE=/tmp/lock.txt
ACSLOGFILE=$1


print_stats(){
    RECORDS_COUNT=$(cat $ACSLOGFILE | wc -l)
    #format pattern to use in print
    format="%7s:%-16s\n"
    start_time_range=$(cat ${ACSLOGFILE}  | cut -d ' ' -f 4 | tail -n $RECORDS_COUNT | sort -n | head -n1 | awk -F"[" '{print $2}')
    finish_time_range=$(cat ${ACSLOGFILE} | cut -d ' ' -f 4 | tail -n $RECORDS_COUNT | sort -nr | head -n1 | awk -F"[" '{print $2}')
    #get top 15 ip adresess
    top_ip=$( cat ${ACSLOGFILE} | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -20 )

    #get top 15 products
    top_products=$( cat ${ACSLOGFILE} | awk '{print $7}' | sort -n | uniq -c | sort -nr | head -20 )

    #get all return codes
    ret_codes=$( cat ${ACSLOGFILE} | awk '{print $9}' | sort -n | uniq -c | sort -nr )

    #get all return codes that 4xx or 5xx
    format_ret_codes=$( cat ${ACSLOGFILE} | awk '$9 ~ /^[54]/ {print $9}' | sort | uniq -c | sort -nr )

    #iutput is kinda ugly, ill fix it later
    printf "Date range: $start_time_range - $finish_time_range\n"
    printf "Top 15 ip adreses:\n"
    printf "$format" "Count" "IP"
    printf "$top_ip\n"
    printf "Top 15 products\n"
    printf "$format" "Count" "Product"
    printf "$top_products\n"
    printf "Return codes:\n"
    printf "$format" "Count" "Code"
    printf "$ret_codes\n"
    printf "Error return codes:\n"
    printf "$format" "Count" "Code"
    printf "$format_ret_codes\n"
}

if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

if [ -z $1 ]; then
    echo "Provide a log file."
    exit 10
elif test -f $1; then
    # make sure the lockfile is removed when we exit and then claim it
    trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
    echo $$ > ${LOCKFILE}

    print_stats
    
    rm -f ${LOCKFILE}
    exit 0
else
    echo "Theres no such file as $1"
    exit 20
fi
