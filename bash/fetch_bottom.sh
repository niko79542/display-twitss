#!/bin/bash

# Variables
EMAIL=jjj.qqqq@gmail.com
RESULTS_FILE="results.txt"
declare -a PHRASES=("told y" "LOLOLOLO" "AHAHAHA" "for sure")
access_token="186cf7e6139a9d6f52af419c3e8c69e85865b84b"
FILENAME="BOTTOM.txt"
CRON_FREQ=5 # in minutes

# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =

# Functions

function get_hours_from_time_ago () {
  HOUR=$(date +%H -d "-$1 minutes")
  HOUR=$(expr $HOUR + 0)
  echo $HOUR
}

function get_minutes_from_time_ago () {
  MINUTE=$(date +%M -d "-$1 minutes")
  MINUTE=$(expr $MINUTE + 0)
  echo $MINUTE
}

function get_days_from_time_ago () {
  DAY=$(date +%j -d "-$1 minutes")
  DAY=$(expr $DAY + 0)
  echo $DAY
}

function set_last_valid_time_and_filename () {
  ALLOWED_HOUR=$(get_hours_from_time_ago 0)
  ALLOWED_MINUTE=$(get_minutes_from_time_ago $CRON_FREQ)
  ALLOWED_DAY=$(get_days_from_time_ago 0)
}

function grep_results () {
  for PHRASE in "${PHRASES[@]}"
    do
       grep -i "${PHRASE}" $RESULTS_FILE | ifne mail -s "${FILENAME} results" "${EMAIL}"
       grep -i "${PHRASE}" $RESULTS_FILE >> totalitarian.txt
    done
}

function check_rate_limited () {
  echo "$2 not successful: status $1"
  if [ $1 == '429' ]
  then
    echo "u dun" | mail -s "rate limited" $EMAIL
    exit 0
  fi
}

# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =
# = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # = # =

set_last_valid_time_and_filename
# echo "ALLOWED TIME: hour: ${ALLOWED_HOUR}, minute: ${ALLOWED_MINUTE}"

cd "$(dirname "$0")"


while read ticker; do
response=$(curl -X GET https://api.stocktwits.com/api/2/streams/symbol/$ticker.json?access_token=$access_token)
status=$(jq -r '.response.status' <<< "${response}")

if [ ${status} == '200' ]
then
  symbol=$(jq -r '.symbol.symbol' <<< "${response}")
  messages=$(jq -r '.messages' <<< "${response}")

  parsed_messages=$(jq -r '[ .[] | {id, body, created_at, username: .user.username, sentiment: .entities.sentiment.basic}]' <<< "${messages}")

  jq -c '.[]' <<< "${parsed_messages}" | while read line; do

    created_at=$(jq -r '.created_at' <<< "${line}")
    MESSAGE_DAY=$(date +%j -d ${created_at})
    MESSAGE_DAY=$(expr $MESSAGE_DAY + 0)

    MESSAGE_HOUR=$(date +%H -d ${created_at})
    MESSAGE_HOUR=$(expr $MESSAGE_HOUR + 0)

    MESSAGE_MINUTE=$(date +%M -d ${created_at})
    MESSAGE_MINUTE=$(expr $MESSAGE_MINUTE + 0)


    DIFF_HOUR=$(expr $MESSAGE_HOUR - $ALLOWED_HOUR)
    DIFF_MINUTE=$(expr $MESSAGE_MINUTE - $ALLOWED_MINUTE)
    DIFF_DAY=$(expr $MESSAGE_DAY - $ALLOWED_DAY)


    if [ ! "$DIFF_MINUTE" -lt "0" ] && [ ! "$DIFF_HOUR" -lt "0" ] && [ ! "$DIFF_DAY" -lt "0" ]
    then
    #  echo "MESSAGE_TIME: HOUR: ${MESSAGE_HOUR}, MINUTE: ${MESSAGE_MINUTE}"
      id=$(jq -r '.id' <<< "${line}")
      body=$(jq -r '.body' <<< "${line}")
      username=$(jq -r '.username' <<< "${line}")
      sentiment=$(jq -r '.sentiment' <<< "${line}")
      echo -e "$id\t$ticker\thttps://stocktwits.com/$username/message/$id\t$body\t$created_at\t$sentiment" >> $RESULTS_FILE
    fi
  done

else
  check_rate_limited $status $ticker
fi
done <$FILENAME

grep_results

rm $RESULTS_FILE
