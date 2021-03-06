@test "bundle config jobs" {
  run bundle config jobs
  current="$(grep -o '"[0-9]*"' <<< $output | sed 's/"//g')"
  [[ -n $current && $current -ge 4 ]]
}

@test "bundle config for nokogiri" {
  run bundle config build.nokogiri
  grep -q -F -- '--use-system-libraries' <<< "$output"
}
