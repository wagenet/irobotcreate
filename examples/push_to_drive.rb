require 'irobotcreate'

# Hit Ctrl-C to end

irc = IRobotCreate::Robot.new
irc.start
irc.full

moving = false

while true
  if irc.sensor_buttons[:play]
    unless moving == :forward
      moving = :forward
      irc.drive_direct(100, 100)
    end
  elsif irc.sensor_buttons[:advance]
    unless moving == :backwards
      moving = :backwards
      irc.drive_direct(-100, -100)
    end
  else
    if moving
      irc.drive_direct(0, 0)
      moving = false
    end
  end
  print "\rVelocity: #{irc.sensor_requested_right_velocity}, #{irc.sensor_requested_left_velocity}        "
end