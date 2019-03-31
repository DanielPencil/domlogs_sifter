#!/bin/bash

clear

        # Setting up colours and 'top offender' (head) amount
ycl=$(tput setaf 6)
ncl=$(tput sgr0)

printf "\nHowdy matey! Take a ${ycl}seat${ncl}! But bring it back at the end of the night, we need them back.\n"

                # Short or extended version
printf "\n\t/---------------------------------------------\\"
printf "\n\t            [ ${ycl}Domlogs Sifter${ncl} v0.1]\n"
printf "\n\t   Please keep in mind that it may take"
printf "\n\t   some time to sift through the logs!"
printf "\n\t\\---------------------------------------------/\n"
printf "\n[${ycl}Options${ncl}]\n[${ycl}1${ncl}] Extended Search\n[${ycl}2${ncl}] Shortened Search\n\n[${ycl}Choice${ncl}]: "
read va0
if [ -z "$va0" ]
then printf "Wrong entry, exiting script.\n"
exit 1
fi

        # This part checks the size of the head it will print out
printf "[${ycl}Block Size${ncl}]: "
read va1
if [ -z "$va1" ]
then va1=10
fi

        # This part checks for the timeframe in regards to how many minutes back will it take a look
printf "[${ycl}Timeframe${ncl}](In minutes): "
read va2
if [ -z "$va2" ]
then va2=1440
fi

                # This variable here is to be able to find for logs that are newer than this and not search for logs that are older.
va2day=$(($va2/1440))

echo $va2day

                # This part checks for whether this search is for a single or all domains
printf "[${ycl}Domain${ncl}]: "
read va3
if [ -z "$va3" ]
then va3="null"
fi

                # Shows the grep time frame
printf "\n[${ycl}Grep range${ncl}]: $(date) \n\t      $(date -d "$va2 min ago")\n"

                # This finds all the searched for logs and pastes the paths to the /root/dtorma_tempfile101.txt file
if [ "$va3" == "null" ]
then find /usr/local/apache/domlogs/ /home/*/logs/ -maxdepth 1 -type f -mtime -$((va2day+1)) -exec echo {} >> /root/dtorma_tempfile101.txt \;

                # This finds all the searched logs for a single domain (only the domain specified, no subdomains indluded)
else find /usr/local/apache/domlogs/ /home/*/logs/ -maxdepth 1 -type f -mtime -$((va2day+1)) | grep "/$va3" >> /root/dtorma_tempfile101.txt
fi

                # These two lines simply paste all the contents from the wanted logs into a single file for easier greping
zcat $(grep .gz /root/dtorma_tempfile101.txt) >> /root/dtorma_tempfile100.txt 2>/dev/null
cat $(cat /root/dtorma_tempfile101.txt) >> /root/dtorma_tempfile100.txt 2>/dev/null

                # this is jusut a temp backup
# (
# echo -e "$(awk -v minTime=$(date -d "$va min ago" '+%Y%m%d%H%M%S') '{split($4,t,/[[ :\/]/);
# mthNr = sprintf("%02d",(index("JanFebMarAprMayJunJulAugSepOctNovDec",t[3])+2)/3);
# curTime = t[4] mthNr t[2] t[5] t[6] t[7]} curTime >= minTime ' /root/dtorma_tempfile100.txt | wc -l)\t/root/dtorma_tempfile100.txt" ;
# )

                # This should grep and count within the designated timeframe
# grep wp-login /root/dtorma_tempfile100.txt | awk -v minTime=$(date -d "$va2 min ago" '+%Y%m%d%H%M%S') '{split($4,t,/[[ :\/]/); mthNr = sprintf("%02d",(index("JanFebMarAprMayJunJulAugSepOctNovDec",t[3])+2)/3); curTime = t[4] mthNr t[2] t[5] t[6] t[7]} curTime >= minTime ' | awk '{print $1}' | sort | uniq -c | sort -rh

if [ "$va0" == "1" ]
then sarray=( wp-login.php xmlrpc.php POST )
for each in "${sarray[@]}"
do
        printf "\nTop %s Offenders of [${ycl}%s${ncl}] requestes\n" $va1 $each
        grep "${each}" /root/dtorma_tempfile100.txt | awk -v minTime=$(date -d "$va2 min ago" '+%Y%m%d%H%M%S') '{split($4,t,/[[ :\/]/); mthNr = sprintf("%02d",(index("JanFebMarAprMayJunJulAugSepOctNovDec",t[3])+2)/3); curTime = t[4] mthNr t[2] t[5] t[6] t[7]} curTime >= minTime ' | awk '{print $1}' | sort | uniq -c | sort -rh | head -$va1 | awk '{printf "%7s - %s\n", $1, $2}'
        echo
done
fi

#rm /root/dtorma_tempfile100.txt /root/dtorma_tempfile101.txt
