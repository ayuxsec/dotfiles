#!/bin/bash

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
  xargs -P 5 -I {} curl-impersonate-chrome {} -X OPTIONS -H "X-Http-Method-Override: GET" --proxy "http://127.0.0.1:8080" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36" -k
}
