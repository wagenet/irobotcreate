require 'irobotcreate'

irc = IRobotCreate::Robot.new
irc.start
irc.full

puts "Starting"

bumped = irc.stream_until(7){|response, checksum| response[7] > 0 }

irc.serial.close

if bumped
  puts "Bumped"
else
  puts "Interrupted"
end

puts "Done"