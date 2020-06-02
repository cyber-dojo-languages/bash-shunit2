
lambda { |stdout,stderr,status|
  return :green if status == 0
  return :amber if /error token is/.match(stderr)
  return :red
}
