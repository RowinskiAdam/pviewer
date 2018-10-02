module PViewer
  module Database
    # EventWriter is a SeriesWriter extension for event handling
    class EventWriter < SeriesWriter
      def initialize(**args, &block)
        super(**args.merge(auto_push: false), &block)
        @points = []
        @merge_same_points = args[:merge_same_points]

        @db_client.writers << self

        self.metadata = args.delete(:metadata) if args[:metadata]
        if args[:experiments]
          @experiment_no = experiment_no
        else
          drop_measurement(**args)
        end
      end

      def add(data)
        add_data(data)
      end

      def finalize
        write
      end

      private

      # resolve overwrite points in more than 1 experiment to 1 measurement
      def experiment_no
        @db_client.scheme(
          database: series.database,
          measurement: series.measurement,
          tag: 'exn'
        ).last.to_i + 1
      end

      def drop_measurement(**args)
        @db_client.drop_measurement(
            database: args[:database] || @db_client.database_name,
            measurement: args[:measurement] || @db_client.measurement_name
        )
      end

      def prepare_values(values)
        values = values.is_a?(Numeric) ? { values: values } : values
        values['~~event'] = 1
        values
      end

      def prepare_tags(tags)
        tags ||= {}

        tags['$index'] = @points.length
        tags['exn'] = @experiment_no if @experiment_no
        tags
      end

      def store_point(point)
        if @merge_same_points && (found = points.find { |e| e == point })
          found.merge!(point)
        else
          points.push(point)
        end
      end

      def write
        return false if points.empty?

        points.each do |point|
          point.process { |values| unpack_values(values) }
        end

        @db_client.write(points.dup, database: series.database)
        @points = []
      end

      def unpack_values(values)
        if values.is_a?(Hash)
          hash_to_fields(values)
        elsif values.is_a?(Array)
          arrays_to_fields(values)
        end
      end

      def hash_to_fields(values)
        array = []

        values.each do |key, obj|
          next array.push([key, obj]) unless obj.is_a?(Array)
          key = key.to_s

          obj.each_with_index do |val, i|
            array.push(["_#{key}_#{i}".to_sym, val])
          end
        end

        array.to_h
      end

      def arrays_to_fields(values)
        values.map!.with_index do |val, i|
          ["_values_#{i}", val]
        end.to_h
      end

      def add_data_default(values: {}, tags: nil, time:)
        if @time != (time = time.to_i)
          write
          @time = time
        end

        values = prepare_values(values)
        tags = prepare_tags(tags)

        point = Point.new(series.measurement, values, tags: tags, time: time)
        store_point(point)
      end

      #def point(values, tags, time)
      #  tags = tags[:tags] || series.tags
      #  time = time[:time]
      #  point = Point.new(series.measurement, values, tags: tags, time: time)
      #  store_point(point)
      #  point
      #end

     def point(vals = nil, values: vals, tags: nil, time: nil)
        tags ||= series.tags
        point = Point.new(series.measurement, values, tags: tags, time: time)
        store_point(point)
        point
     end

    end
  end
end
