# frozen_string_literal: true

option = {}
ARGV.each do |arg|
  key, value = arg.split("=")
  option[key] = value || true
end

name = option["name"]
exit_code = option["exit"].to_i
output = option["stdout"]
error = option["stderr"]

if option["read_stdin"]
  input = STDIN.read
  puts "#{name}: got: #{input}"
end
puts output if output
warn error if error
exit exit_code
