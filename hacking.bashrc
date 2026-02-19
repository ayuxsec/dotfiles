#!/usr/bin/env bash

ua_header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36"
color_green="\e[32m"
color_yellow="\e[33m"
color_normal="\e[0m"

ansi_filter() {
  sed 's/\x1B\[[0-9;]*[mK]//g'
}

rustscan_common_ports() {
  [ "$#" -eq 0 ] && { echo "usage: rustscan_common_ports <host>"; return 1; }
  rustscan -a $1 -g -t 5000 -b 500 -p 21,22,5432,3306,25,88,389,445,636,1443,6379,27017,9200,1521
}

ipinfo() {
  local base_url="https://ipinfo.io"
  [ "$#" -eq 0 ] && { echo "Usage: ipinfo <ip_addr>"; return 1; }
  [[ -v ipinfo_api_key ]] && { curl -s "$base_url/$1" -H  "Authorization: Bearer ${ipinfo_api_key}"; return 0; }
  curl -s $base_url/$1
}

method_bypass() {
  code=$(curl-impersonate-chrome -s -o /dev/null -X OPTIONS -H "X-Http-Method-Override: GET" -H "$ua_header" -w "%{http_code}" "$1")
  echo -e "[+] URL: $1 [~] status_code: $color_yellow$code$color_normal"
}

cors_null_check() {
  [ "$#" -eq 0 ] && { echo "Usage: cors_null_check <url>"; return 1; }
  echo "[+] URL: $1"
  curl-impersonate-chrome $1 -H "Origin: null" -H "$ua_header -I" -s | grep -iE "Access-Control-Allow-Origin: null|Access-Control-Allow-Credentials: true"
}

google_firebase_apikey_checker() {
  [ "$#" -eq 0 ] && { echo "Usage: google_firebase_apikey_checker <key>"; return 1; }
  local api_key="$1"
  local data='{"longDynamicLink": "https://sub.example.com/?link=https://example.org"}'
  response=$(curl -s -X POST "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=$api_key" -H 'Content-Type: application/json' -d "$data")
  [[ $response != *"API key not valid"* ]] && { echo "$api_key; return 0"; }
}

append_param() {
  local param="$1"
  while read -r url; do
    if [[ "$url" == *\?* ]]; then
      echo "${url}&${param}"
    else
      echo "${url}?${param}"
    fi
  done
}


jsscan() {
  [ "$#" -ne 1 ] && { echo "Usage: jsscan <url_file>"; return 1; }
  temp_dir=$(mktemp -d)
  # trap 'rm -rf "$tmp_dir"' EXIT

  cat $1 | \
    xargs -P 5 -I {} curl-impersonate-chrome {} -s -H "$ua_header" >> \
    "$temp_dir"/"$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)".js
  
  trufflehog filesystem "$temp_dir" --results=verified

  echo "[+] saved to ${temp_dir}"
}


