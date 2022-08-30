#!/bin/bash
# Canarytoken-GreyNoise-Enterprise-Threat-Intel-Report.sh
# Justin Varner
# August 30, 2022

# Fetch all incidents and filter out only IP addresses. Then write to a text file
curl https://$CANARY_HASH.canary.tools/api/v1/incidents/all -d auth_token=$CANARY_TOKEN -G | jq '.' | grep -o '"src_host": "[^"]*' | grep -o '[^"]*$' | sort -u > canary-ips-$(date +%Y-%m-%d).txt

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
