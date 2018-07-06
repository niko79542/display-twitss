#!/bin/bash

# Variables
EMAIL=jjj.qqqq@gmail.com
RESULTS_FILE="results.txt"
INTERMEDIARY="validmsgs.txt"
JSONIFIED_FILE="../client/build/results.json"
declare -a PHRASES=("told y" "LOLOLOLO" "AHAHAHA" "for sure")
access_token="186cf7e6139a9d6f52af419c3e8c69e85865b84b"
FILENAME="TOP.txt"
CRON_FREQ=2 # in minutes
touch $RESULTS_FILE
touch $INTERMEDIARY


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
       grep -i "${PHRASE}" $RESULTS_FILE >> $INTERMEDIARY
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

function keyify () {
  echo "\"$1\": \"$2\""
}

function prepare_json_file() {
  rm $JSONIFIED_FILE
  touch $JSONIFIED_FILE
  echo "[" >> $JSONIFIED_FILE
  cat $INTERMEDIARY | paste -sd, - >> $JSONIFIED_FILE
  echo "]" >> $JSONIFIED_FILE
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
response=$(curl -X GET https://api.stocktwits.com/api/2/streams/symbol/$ticker.json)
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

    id=$(jq -r '.id' <<< "${line}")
    body=$(jq -r '.body' <<< "${line}")
    clean_body=${body//_/}
  # next, replace spaces with underscores
    clean_body=${clean_body// /_}
    # now, clean out anything that's not alphanumeric or an underscore
    clean_body=${clean_body//[^a-zA-Z0-9_]/}


    username=$(jq -r '.username' <<< "${line}")
    sentiment=$(jq -r '.sentiment' <<< "${line}")
    url="https://stocktwits.com/$username/message/$id"

    key_id="\"id\": $id"
    key_ticker=$(keyify 'ticker' $ticker)
    key_url=$(keyify 'url' $url)
    key_body=$(keyify 'body' $clean_body)
    key_created_at=$(keyify 'created_at' $created_at)
    key_sentiment=$(keyify 'sentiment' $sentiment)

    if [ ! "$DIFF_MINUTE" -lt "0" ] && [ ! "$DIFF_HOUR" -lt "0" ] && [ ! "$DIFF_DAY" -lt "0" ]
    then
    #  echo "MESSAGE_TIME: HOUR: ${MESSAGE_HOUR}, MINUTE: ${MESSAGE_MINUTE}"
      echo -e "{$key_id,$key_ticker,$key_url,$key_body,$key_created_at,$key_sentiment}" >> $RESULTS_FILE
    fi
  done

else
  check_rate_limited $status $ticker
fi
done <$FILENAME

grep_results

rm $RESULTS_FILE


prepare_json_file
