ansi_filter() {
  sed 's/\x1B\[[0-9;]*[mK]//g'
}
