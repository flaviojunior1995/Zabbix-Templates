#!/bin/bash
: <<"DEPENDENCIAS"

curl -> apt install curl
montage -> apt install imagemagick

DEPENDENCIAS

### INICIO VARIAVEIS ###

TELEGRAM_CHAT_ID=$1
subject=$2
message=$3
triggerid=$(echo $subject |  cut -d# -f1 )
eventid=$(echo $subject | cut -d# -f2 )
graph_x=$(echo $subject | cut -d# -f3 )
graph_y=$(echo $subject | cut -d# -f4 )
graph_time=$(echo $subject | cut -d# -f5 )

ZABBIX_URL="https://127.0.0.1"
ZABBIX_USER="Admin"
ZABBIX_PASSWORD="zabbix"

TELEGRAM_TOKEN="2141617274:AAF0kqyoKklOuJLc1F1SujCuWmU0EYlaWoA"
#TELEGRAM_CHAT_ID=

## FIM VARIAVEIS ##

## AUTENTICACAO ZABBIX
auth=$(curl -s --data '{ "jsonrpc": "2.0", "method": "user.login", "params": { "user": "'"$ZABBIX_USER"'", "password": "'"$ZABBIX_PASSWORD"'" }, "id": 1 }' --header 'Content-Type: application/json' --insecure $ZABBIX_URL/api_jsonrpc.php | jq -r .result)

## GET ITEMS
trigger=$(curl -s -X POST --header 'Content-Type: application/json-rpc' \
--data " \
{
\"jsonrpc\": \"2.0\",
\"method\": \"trigger.get\",
\"params\": {
 	\"triggerids\": \"$triggerid\",
	\"selectItems\": \"['name', 'value_type', 'lastvalue']\",
	\"selectHosts\": \"['name']\"
},
\"auth\": \"$auth\",
\"id\": 1
}
" --insecure $ZABBIX_URL/api_jsonrpc.php )

trigger_items_count=$(echo $trigger | jq '.result[].items | length')

## SALVAR GRAPHS
for i in $(seq 1 $trigger_items_count); do
  n=$(( $i - 1 ))
  itemid=$(echo $trigger | jq -r '.result[].items['"$n"'].itemid' )
  ## GET GRAPH
  curl -s --cookie "zbx_sessionid=$auth" --insecure "$ZABBIX_URL/chart.php?itemids%5B0%5D=${itemid}&height=${graph_x}&width=${graph_y}&from=now-${graph_time}h&to=now&profileIdx=web.charts.filter&_=up0bkgs0" -o /tmp/${eventid}_${triggerid}_${n}.png
done

## MERGE GRAPHS IMAGES
montage /tmp/${eventid}_${triggerid}_*.png -geometry +2+2 /tmp/${eventid}_${triggerid}_merge.png

## ENVIAR GRAPHS TELEGRAM + MENSAGEM
curl -s -X POST --form "chat_id=$TELEGRAM_CHAT_ID" --form "photo=@/tmp/${eventid}_${triggerid}_merge.png" https://api.telegram.org/bot$TELEGRAM_TOKEN/sendphoto \
 --form "photo=@/tmp/${eventid}_${triggerid}_merge.png" \
 --form 'caption="'"$message"'"'

## CLEANUP
rm /tmp/${eventid}_${triggerid}_*
