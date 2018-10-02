module PViewer
  module Database
    #
    # Series reader supports data reading.
    # Should be initialized by database client that ensure self as param.
    # Comparing on series basis, details in a series class file.
    #
    class SeriesReader
      attr_reader :series

      def initialize(**args, &block)
        raise MissingClient unless (@db_client = args[:db_client])

        args[:database] ||= @db_client.database_name
        args[:measurement] ||= @db_client.measurement_name

        @series = Series.new(**args)
        @custom_action = block if block_given?
      end

      def read(**args)
        read_data(**args)
      end

      def ==(other)
        series == other.series
      end

      def eql?(other)
        series.eql? other.series
      end

      private

      def read_data(**args)
        epoch = args.delete(:epoch) if args[:epoch]
        series = args.empty? ? @series : args_to_series(args)

        data = @db_client.read(series, epoch.nil? ? {} : { epoch: epoch })

        @custom_action.nil? ? data : @custom_action.call(data)
      end

      def args_to_series(**args)
        args[:database] ||= series.database
        args[:measurement] ||= series.measurement
        args.merge!(series.options)
        Series.new(args)
      end
    end
  end
end
