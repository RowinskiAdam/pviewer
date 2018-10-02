module PViewer
  module Handler
    # Counters handles with counters events.
    class Counters
      def initialize(**args)
        args[:measurement] ||= args[:db_client].measurement_name
        args[:measurement] = args[:measurement] + ' [counters]'

        @reader = args[:db_client].event_reader(**args)
        @writer = args[:db_client].event_writer(**args)
      end

      def write(**args)
        @writer.add(**args)
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