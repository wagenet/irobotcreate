module IRobotCreate
  class SensorCommand < Command

    attr_reader :sensor_code, :response_size, :response_type, :response_options

    @@sensor_commands = {}

    class << self

      def register(name, *args)
        @@sensor_commands[name] = new(*args)
      end

      def [](name)
        @@sensor_commands[name.to_sym]
      end

    end

    def initialize(sensor_code, response_size, response_type, response_options = nil)
      super(142, 1)
      @sensor_code = sensor_code
      @response_size = response_size
      @response_type = response_type
      @response_options = response_options
    end

    def run(robot)
      super(robot, sensor_code)

      response = robot.read_response(response_size)

      case response_type
      when :boolean
        response.first == 1
      when :integer, :signed_integer
        integer = 0
        response_size.times do |i|
          integer += response[i] * (256 ** ((response_size - 1) - i))
        end

        if response_type == :signed_integer
          max = 256 ** response_size
          if integer > max / 2
            integer -= max
          end
        end

        integer
      when :map
        response_options[response.first]
      when :compound
        hash = {}
        options_size = response_options.size
        options_size.times do |i|
          item = response_options[i]
          next unless item
          hash[item] = response.first & 2**((options_size - 1) - i) != 0
        end
        hash
      else
        response
      end
    end

  end

  SensorCommand.class_eval do
    register :bump_drop,                7,  1, :compound, [:wheeldrop_caster, :wheeldrop_left, :wheeldrop_right, :bump_left, :bump_right]
    register :wall,                     8,  1, :boolean
    register :cliff_left,               9,  1, :boolean
    register :cliff_front_left,         10, 1, :boolean
    register :cliff_front_right,        11, 1, :boolean
    register :cliff_right,              12, 1, :boolean
    register :virtual_wall,             13, 1, :boolean
    register :low_side_and_wheels,      14, 1, :compound, [:left_wheel, :right_wheel, :ld2, :ld0, :ld1]
    register :ir,                       17, 1, :map, { 129 => :left, 130 => :forward, 131 => :right, 132 => :spot, 133 => :max, 
                                                        134 => :small, 135 => :medium, 136 => :large, 137 => :pause, 138 => :power,
                                                        139 => :arc_left, 140 => :arc_right, 141 => :drive_stop }
    register :buttons,                  18, 1, :compound, [:advance, nil, :play]
    register :distance,                 19, 2, :signed_integer
    register :angle,                    20, 2, :signed_integer
    register :charging,                 21, 1, :map, { 0 => :not_charging, 1 => :reconditioning, 2 => :full, 3 => :trickle,
                                                        4 => :waiting, 5 => :fault }
    register :voltage,                  22, 2, :integer
    register :current,                  23, 2, :signed_integer
    register :battery_temperature,      24, 1, :signed_integer
    register :battery_charge,           25, 2, :integer
    register :battery_capacity,         26, 2, :integer
    register :wall_signal,              27, 2, :integer
    register :cliff_left_signal,        28, 2, :integer
    register :cliff_front_left_signal,  29, 2, :integer
    register :cliff_front_right_signal, 30, 2, :integer
    register :cliff_right_signal,       31, 2, :integer
    register :cargo_bay_digital,        32, 1, :compound, [:detect, :input3, :input2, :input1, :input0]
    register :cargo_bay_analog,         33, 2, :integer
    register :charging_sources,         34, 1, :compound, [:home_base, :internal]
    register :oi_mode,                  35, 1, :map, { 0 => :off, 1 => :passive, 2 => :safe, 3 => :full }
    register :song_number,              36, 1, :integer
    register :song_playing,             37, 1, :boolean
    register :stream_packets_count,     38, 1, :integer
    register :requested_velocity,       39, 2, :signed_integer
    register :requested_radius,         40, 2, :signed_integer
    register :requested_right_velocity, 41, 2, :signed_integer
    register :requested_left_velocity,  42, 2, :signed_integer
  end

end