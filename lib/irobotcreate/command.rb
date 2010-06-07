module IRobotCreate

  class Command

    attr_reader :code, :argument_options

    @@commands = {}

    class << self

      def register(name, *args)
        @@commands[name] = new(*args)
      end

      def [](name)
        @@commands[name.to_sym]
      end

    end

    def initialize(code, argument_options = [])
      @code = code

      if argument_options != :inf
        case argument_options
        when Integer
          argument_options = [{ :type => :integer }] * argument_options
        when Symbol
          argument_options = [{ :type => argument_options }]
        when Array
          argument_options.map!{|ao| ao.is_a?(Hash) ? ao : { :type => ao } }
        when Hash
          argument_options = [argument_options]
        else
          raise "Can't handle argument options: #{argument_options}"
        end
      end

      @argument_options = argument_options
    end

    def run(robot, *args)
      if argument_options == :inf
        array = args
      else
        if IRobotCreate::DEBUG
          puts "args: #{args.inspect}"
          puts "argument_options: #{argument_options.inspect}"
        end
        if args.size != argument_options.size
          raise ArgumentError, "Requires #{argument_options.size} arguments"
        end

        array = []
        args.each_with_index do |arg, i|
          opts = argument_options[i]

          value = arg
          puts "starting value: #{value.inspect}" if IRobotCreate::DEBUG

          size = opts[:size] || 1

          if opts[:inverse_map]
            opts[:map] = opts[:inverse_map]
            for k,v in opts[:inverse_map]
              opts[:map]["not_#{k}".to_sym] = 256**size - v
            end
            puts "inverse_map: #{opts[:map.inspect]}" if IRobotCreate::DEBUG
          end

          if opts[:map]
            value = opts[:map][value]
            puts "mapped: #{value}" if IRobotCreate::DEBUG
            raise "Couldn't map value" if value.nil?
          end

          if opts[:compound]
            raise "Compound size must be 1!" unless size == 1

            value_array = value.is_a?(Array) ? value : [value]
            value = 0

            compound_size = opts[:compound].size
            compound_size.times do |j|
              compound_value = opts[:compound][j]
              puts "checking for #{compound_value}" if IRobotCreate::DEBUG
              if compound_value && value_array.include?(compound_value)
                bit = (compound_size - 1) - j
                puts "Adding bit: #{bit}" if IRobotCreate::DEBUG
                value += 2 ** bit
              end
            end
          elsif opts[:type] == :boolean
            value = value ? 1 : 0
          end

          puts "preprocessed value: #{value.inspect}" if IRobotCreate::DEBUG

          if value < 0
            value += 256 ** size
            puts "converted negative: #{value.inspect}" if IRobotCreate::DEBUG
          end

          size.times do |j|
            base = 256 ** ((size - 1) - j)
            current = value / base
            value %= base
            array << current
          end

          puts "array: #{array.inspect}" if IRobotCreate::DEBUG
        end
      end

      puts "final array: #{array.inspect}" if IRobotCreate::DEBUG

      robot.send([code] + array)
    end

  end

  Command.class_eval do
    register :start,          128
    register :baud,           129, :map => { 300 => 0, 600 => 1, 1200 => 2, 2400 => 3, 4800 => 4, 9600 => 5, 14440 => 6,
                                             19200 => 7, 28800 => 8, 38400 => 9, 57600 => 10, 115200 => 11 }
    register :safe,           131
    register :full,           132
    register :demo,           136, :map => { :abort => -1, :cover => 0, :cover_and_dock => 1, :spot_cover => 2, :mouse => 3,
                                             :figure_eight => 4, :wimp => 5, :home => 6, :tag => 7, :pachelbel => 8, :banjo => 9 }
    register :cover,          135
    register :cover_and_dock, 143
    register :spot,           134
    register :drive,          137, [{ :size => 2 }, { :size => 2 }]
    register :drive_direct,   145, [{ :size => 2 }, { :size => 2 }]
    register :leds,           139, [{ :compound => [:advance, nil, :play, nil ]}, :integer, :integer]
    register :digital,        147, :compound => [:output2, :output1, :output0 ]
    register :pwm,            144, 3
    register :driver,         138, :compound => [:side_driver2, :low_side_driver1, :low_side_driver0]
    register :ir,             151, 1
    register :song,           140, :inf
    register :play_song,      141, 1
    register :sensors,        142, 1
    register :query,          149, :inf
    register :stream,         148, :inf
    register :stream_playing, 150, :boolean
    register :script,         152, :inf
    register :play_script,    153
    register :show_script,    154
    register :wait_time,      155, 1
    register :wait_distance,  156, :size => 2
    register :wait_angle,     157, :size => 2
    register :wait_event,     158, :inverse_map => { :wheel_drop => 1, :front_wheel_drop => 2, :left_wheel_drop => 3, :right_wheel_drop => 4,
                                                      :bump => 5, :left_bump => 6, :right_bump => 7, :virtual_wall => 8, :wall => 9,
                                                      :cliff => 10, :left_cliff => 11, :front_left_cliff => 12, :front_right_cliff => 13,
                                                      :right_cliff => 14, :home_base => 15, :advance_button => 16, :play_button => 17,
                                                      :digital0 => 18, :digital1 => 19, :digital2 => 20, :digital3 => 21, :oi_passive => 22 }
  end

end
