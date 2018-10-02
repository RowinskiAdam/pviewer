module PViewer
  module Handler
    # Values handles with values events.
    class Values
      def initialize(**args)
        args[:measurement] ||= args[:db_client].measurement_name
        args[:measurement] = args[:measurement] + ' [values]'
        args[:merge_same_points] = true

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
