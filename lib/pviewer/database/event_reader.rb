require_relative 'gui_format'
require_relative 'reduction_types'

module PViewer
  module Database
    # SeriesReader extension for events handling.
    class EventReader < SeriesReader
      include GUIFormat
      include ReductionTypes

      def initialize(**args, &block)
        super(args, &block)

        @gui_format = args[:gui_format]
        @reduce_type = args[:reduce_type]
        @time_precision = args[:time_precision]

        series.options[:selector] = '/^[^$].*/'

        define_reduce(args[:reduce_type] || :first)
      end

      def read(**args)
        @reduce_type = args[:reduce].delete if args[:reduce]
        series.options[:group_by] = fetch_tags.join('", "')
        super(**args)
      end

      private

      def fetch_tags
        args = { database: series.database, measurement: series.measurement }
        tags = @db_client.scheme(args)
        tags.reject! do |e|
          e == 'type' || e.start_with?('$')
        end
        tags
      end

      def define_reduce(reduce_type)
        method_sym = reduce_type.downcase.to_sym

        return unless respond_to?(method_sym)

        define_singleton_method(:reduce) do |value|
          method(method_sym).call(value)
        end
      end

      def read_data(**args)
        if @gui_format == 'Summary' || series.measurement.match?(/\[durations\]/)
          args[:epoch] = args[:epoch] || @time_precision
        end

        return { values: {}, tags: {} } unless (data = super(args))

        data.map do |element|
          mapped = map_element(element)
          @gui_format ? to_gui_format(mapped) : mapped
        end
        data
      end

      def map_element(element)
        data = pack(element)

        data['tags'] = data['tags'].reject { |_, v| v.empty? } if data['tags']
        if (index = data['columns'].find_index('type'))
          data['columns'].delete_at(index)
          data['values'] = data['values'].group_by { |e| e.delete_at(index) }
        end
        data
      end

      def pack(data)
        columns = columns_to_pack(data['columns']).except!('~~event')

        data['columns'] = columns.keys

        data['values'].map! do |point|
          join_array_fields(point, columns)
        end

        data
      end

      def columns_to_pack(columns_names)
        indexes = {}
        columns_names.each_with_index do |v, i|
          if suitable_to_pack?(v)
            key = prepare_field_name(v)
            (indexes[key] ||= []).push(i)
          else
            (indexes[v] ||= []).push(i)
          end
        end
        indexes
      end

      def suitable_to_pack?(value)
        value.match?(/_*_[0-9]+/)
      end

      def prepare_field_name(name)
        name[0] = ''
        name.gsub(/_[0-9]+/, '')
      end

      def join_array_fields(point, columns)
        columns.map do |name, indexes|
          selected = point.select.with_index { |_, i| indexes.include?(i) }
          if selected.length == 1 && (name != 'values' || selected.empty?)
            selected.first
          else
            selected.compact!
            @reduce_type ? reduce(selected) : selected
          end
        end
      end
    end
  end
end
