#!/bin/bash
# Canary-GreyNoise-Enterprise-Threat-Intel-Report.sh
# Justin Varner
# August 30, 2022

## Fetch all bird events and filter out the IP then write to a text file
curl -XGET "https://$CANARY_HASH.canary.tools/api/v1/incidents/outside_bird/download/json" \
  -d auth_token=$CANARY_TOKEN \
  -d node_id=$BIRD_ID \
  -G -O -J \
  && unzip outside_bird_alerts.json.zip \
  && cat outside-bird-$BIRD_ID.json | jq '.[].ip_address' | sed 's/\"//g' | sort > canary-ips-$(date +%Y-%m-%d).txt

## Read all IPs from a text file and run through Shodan for threat intel
file="canary-ips-$(date +%Y-%m-%d).txt"
lines=$(cat $file)

{
for line in $lines
do >/dev/null 2>&1
    curl -XGET "https://api.greynoise.io/v2/noise/context/$line" \
      -H "key: $GREYNOISE_TOKEN" \
      -H "accept: application/json" | jq '.' | cat >> Canarytoken-GreyNoise-Enterprise-Threat-Intel-Report-$(date +%Y-%m-%d).json
done
} > /dev/null 2>&1
