#!/bin/bash

export LANG=C
#show all with specified parent

TMPDIR=/tmp/render
mkdir -p $TMPDIR

show(){
    local file=$1; shift
    local parent=$1; shift
    local offset=$1; shift  
    local x y                       

    ((x=offset*3))                          
    ((offset++))                                    

    egrep "^$parent " "$file" |\
    while read parent class rate ceil now tokens ctokens lended borrowed trash; do
        #SKIP 0 RATE SHAPER!!!!!!!!!!!!!!!!!!                                           
        #       [ -z "$now" ] && continue                                                               
        #       [ "$now" = 0Kbit ] && continue                                                                          
        #SKIP 0 RATE SHAPER!!!!!!!!!!!!!!!!!!                                                                                           
        printf "%${x}.${x}s" '';                                                                                                                        
        echo "$class rate=$rate ceil=$ceil now=$now" # tokens=$tokens ctokens=$ctokens lended=$lended borrowed=$borrowed"                                               
        show "$file" $class $offset                                                                                                                                                     
    done                                                                                                                                                                                            
}                                                                                                                                                                                               

usage() {
    echo "Usage: $0 {imq1|imq0}"
    exit 1
}

main() {
    dev="$1"
    local rates=$TMPDIR/${dev}_with_rate.$$
    local rates2=$TMPDIR/${dev}_with_rate2.$$
    local hierarchy=$TMPDIR/${dev}_hierarchy.$$

    tc -s class show dev $dev | egrep '^ rate' -B2 -A2 > $rates
    tc class show dev $dev | sed -r 's/^class htb ([^ ]+) ((parent ([^ ]+))|(root)) .*rate ([^ ]+) ceil ([^ ]+) .*$/\4\5 \1 \6 \7/' | sort -k2,2 > $hierarchy

    while true; do
        read class_w class_t class parent_w parent leaf_w leaf prio_w prio rate_w rate ceil_w ceil burst_w burst cburst_w cburst trash || break
        read trash || break                                
        read current_rate_w current_rate current_pps trash || break
        read lended_w lended borrowed_w borrowed giants_w giants trash || break
        read tokens_w tokens ctokens_w ctokens trash || break
        current_rate="${current_rate//bit/}"
        current_rate="${current_rate//Kbit/*1024}"
        current_rate="${current_rate//Mbit/*1024*1024}"               
        current_rate="${current_rate//bps/*8}"                                                
        current_rate=$(($current_rate/1024))                                                                          
        echo "$class ${nowrate}Kbit $tokens $ctokens $lended $borrowed"                                                             
        read trash || break                                                                                                                                 
    done < "$rates" | sort | join -a 1 -1 2 -2 1 -o 1.1,1.2,1.3,1.4,2.2,2.3,2.4,2.5,2.6 "$hierarchy" - | sort -k4,4nr -k5,5nr > "$rates2"

    show "$rates2" root 0                                                                                                                     
}                                                                                                                                              

if [ "$#" = "0" ]; then
    for dev in imq0 imq1; do
        echo "$dev"
        main "$dev"
        echo
    done
else
    [[ "$1" = imq[01] ]] || usage
    main "$@"
fi
