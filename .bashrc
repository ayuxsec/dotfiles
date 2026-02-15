#!/bin/bash

ansi_filter() {
  sed 's/\x1B\[[0-9;]*[mK]//g'
}

rustscan_common_ports() {
  [ "$#" -eq 0 ] && { echo "usage: rustscan <host>"; return 1; }
  rustscan -a $1 -g -t 5000 -b 500 -p 21,22,5432,3306,25,88,389,445,636,1443,6379,27017,9200,1521
}
