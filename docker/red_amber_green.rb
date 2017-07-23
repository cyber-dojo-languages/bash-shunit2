
lambda { |stdout,stderr,status|
  output = stdout + stderr
  return :amber if /shunit2:ERROR/.match(output)
  return :red   if /Ran (\d+) test(s?)\.\n\nFAILED/.match(output)
  return :green if /Ran (\d+) test(s?)\.\n\nOK/.match(output)
  return :amber
}
