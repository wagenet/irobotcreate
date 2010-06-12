module IRobotCreate
  module Helpers
    module Stream

      def stream_until(packet)
        stream_started = false
        stopped = false

        stream(1, 7)

        until stopped

          unless stream_started
            # Don't always check for 19 because we don't always get it, just wait for the first one
            # and then assume everything else is part of the stream
            stream_started = read_response == 19
          end

          if stream_started
            remaining = read_response

            # This may not be a good assumption, but since we sometimes get 19 and sometimes not,
            # we need to account for it somehow
            if remaining == 19
              remaining = read_response
            end

            response = {}

            # For now assume each packet is only one long
            while remaining > 0
              pid = read_response
              value = read_response
              response[pid] = value
              remaining -= 2
            end

            # TODO: Look at checksum
            checksum = read_response

            if yield(response, checksum)
              stopped = true
            end
          end
        end

        stream_playing(false)

        return stopped
      end

    end
  end
end