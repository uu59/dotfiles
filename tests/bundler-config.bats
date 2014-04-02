@test "bundle config jobs" {
  run bundle config jobs
  current=$(grep -o '[0-9]*' <(echo $output))
  [[ -n $current && $current -ge 4 ]]
}
