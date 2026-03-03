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
  puts "#{name}: got: #{input}" # rubocop:disable RSpec/Output
end
puts output if output # rubocop:disable RSpec/Output
warn error if error
exit exit_code
