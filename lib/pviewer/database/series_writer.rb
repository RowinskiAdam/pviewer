require_relative 'point'

module PViewer
  module Database
    #
    # Intended as a simple class that supports data storage.
    # Should be initialized by database client that ensure self as param.
    #
    # Examples:
    #
    # database = Client.new
    #
    # series = database.series_writer('series1')
    #
    # series.add(x: 5, tags: { level: 'normal' })
    #
    # or non default data formatting
    #
    # series = database.series_writer('series1') do |data|
    #   data.each_with_index do |element, i|
    #     point x: element, tags: { no: i }
    #   end
    #
    # series.add([100, 200, 300])
    #
    # If using Influx, note that the database does not allow to write points
    # with same timestamp and tags.
    #
    # Unless tags specified will be used same as at initialization.
    # Unless database name specified will be used default.
    #
    class SeriesWriter
      attr_reader :series, :points

      def initialize(**args, &block)
        raise MissingClient unless (@db_client = args[:db_client])

        @series = create_series(args)
        @custom_formatter = block
      end

      def add(data)
        copy = dup
        copy.__send__(:add_data, data)
        copy
      end

      def dup
        copy = super
        copy.instance_variable_set(:@points, [])
        copy
      end

      def metadata=(text)
        old_metadata = series.metadata
        series.metadata = text
        series.metadata = (@db_client.metadata = series) || old_metadata
      end

      def metadata
        series.metadata
      end

      private

      def create_series(args)
        args[:database] ||= @db_client.database_name
        args[:measurement] ||= @db_client.measurement_name

        series = Series.new(args)
        series.metadata = @db_client.metadata(series)
        series
      end

      def add_data(data)
        if @custom_formatter
          instance_exec data, &@custom_formatter
        else
          add_data_default(data)
        end
      end

      def add_data_default(data)
        data = prepare_data(data)
        points.push(
          Point.new(series.measurement, data[:values],
                    tags: data[:tags], time: data[:time])
        )
        write
      end

      def prepare_data(**data)
        unless data.key?(:values)
          tags = data.delete(:tags) || series.tags
          time = data.delete(:time)
          data = { values: data, tags: tags, time: time }.compact!
        end
        data
      end

      def point(vals = nil, values: vals, tags: nil, time: nil)
        tags ||= series.tags
        point = Point.new(series.measurement, values, tags: tags, time: time)
        points.push(point)
      end

      def write
        return false if points.empty?
        @db_client.write(points, database: series.database)
      end
    end
  end
end
