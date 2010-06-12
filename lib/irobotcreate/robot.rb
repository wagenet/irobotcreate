require 'serialport'

module IRobotCreate

  class Robot

    include IRobotCreate::Helpers::Stream

    DEFAULT_PORT = '/dev/tty.ElementSerial-ElementSe'

    attr_reader :serial

    def initialize(port = DEFAULT_PORT, args = {})
      args = { :baudrate => 57600, :databits => 8, :stopbits => 1 }.merge(args)
      @serial = SerialPort.new(port, args)
    end

    def format_bytes(arg)
      array = case arg
        when String
          arg.split(/\s+/).map(&:to_i)
        when Array
          arg
        else
          [arg]
      end

      array.pack('C*')
    end

    def send(cmd)
      serial.write format_bytes(cmd)
    end

    # FIXME: Occasionally this reads too many
    def read_response(size=nil)
      response = (0...(size || 1)).map{|_| serial.getc }.join.unpack('C*')
      size.nil? ? response.first : response
    end

    def run_command(name, *args)
      Command[name].run(self, *args)
    end

    def check_sensor(name)
      SensorCommand[name].run(self)
    end

    def method_missing(sym, *args, &block)
      if sym.to_s =~ /^sensor_(.*)$/ && SensorCommand[$1]
        check_sensor($1)
      elsif Command[sym]
        run_command(sym, *args, &block)
      else
        super
      end
    end

  end

end