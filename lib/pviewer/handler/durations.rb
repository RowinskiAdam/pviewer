module PViewer
  module Handler
    # Durations handles with durations events.
    class Durations
      def initialize(**args)
        args[:measurement] ||= args[:db_client].measurement_name
        args[:measurement] = args[:measurement] + ' [durations]'

        @reader = args[:db_client].event_reader(**args)
        @writer = args[:db_client].event_writer(**args)
      end

      def write(**args)
        @writer.add(**args)
      end

      def start(**args)
        args[:type] = :start
        write(**args)
      end

      def stop(**args)
        args[:type] = :stop
        write(**args)
      end

      def read(**args)
        @reader.read(**args)
      end

      def metadata
        @writer.metadata
      end

      def metadata=(text)
        @writer.metadata = text
      end
    end
  end
end
