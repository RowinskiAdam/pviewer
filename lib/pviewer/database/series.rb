module PViewer
  module Database
    # Default series struct.
    # Comparison using == and eql? is not same.
    class Series
      attr_reader :database, :measurement, :tags
      attr_accessor :metadata, :options

      def initialize(database:, measurement:, **args)
        @database = database
        @measurement = measurement
        @tags = args[:tags]
        @metadata = args[:metadata]
        @options = fetch_options(args)
      end

      def to_h
        ivars = instance_variables.reject do |ivar|
          ivar == :@options || ivar == :@hash
        end

        ivars.map do |var|
          [var[1..-1].to_sym, instance_variable_get(var)]
        end.to_h.merge(@options).compact
      end

      def ==(other)
        [@database, @measurement, @tags] ==
          [other.database, other.measurement, other.tags]
      end

      def eql?(other)
        hash == other.hash
      end

      def hash
        [@database, @measurement, @tags].hash
      end

      private

      def fetch_options(args)
        {
          aggregate_function: args[:aggregate_function],
          group_by: args[:group_by],
          selector: args[:selector],
          subquery: args[:subquery]
        }
      end
    end
  end
end