module PViewer
  module Database
    # Event reader extension, parse data to gui format.
    module GUIFormat
      private

      def to_gui_format(data)
        if data['name'].match?(/\[durations\]/)
          format_durations(data)
        elsif data['name'].match?(/\[counters\]/)
          format_counters(data)
        else
          format_values(data)
        end
      end

      def format_durations(data)
        if @gui_format == 'Summary'
          name = data['tags'].map { |k, v| k + ': ' + v }.join(', ')
          data['columns'].unshift('tags').delete('time')
        end

        data['columns'].push('duration')
        data['values'] = count_durations(data['values'], name)
        data
      end

      def count_durations(data, name = nil)
        starts = data['start'].flatten
        stops = data['stop'].flatten
        start_stop = starts.zip(stops)


        start_stop.map do |start, stop|
          next nil if stop.nil?
          [name || strf_to_precision(start),
           (stop - start).abs]
        end.compact
      rescue
        start_stop.pop unless start_stop.nil?
        start_stop
      end

      def format_counters(data)
        if @gui_format == 'Summary'
          data['columns'].unshift('tags').delete('time')
        end

        data['columns'].push('event')
        data['values'] = map_counters(data)
        data
      end

      def map_counters(data)
        if @gui_format == 'Summary'
          name = data['tags'].map { |k, v| k + ': ' + v }.join(', ')
          data['values'].map { |_e| [name, 1] }
        else
          data['values'].flatten.zip(Array.new(data['values'].length, 1))
        end
      end

      def format_values(data)
        if @gui_format == 'Summary'
          name = data['tags'].map { |k, v| k + ': ' + v }.join(', ')

          data['columns'].unshift('tags').delete('time')
          data['values'].map! { |_, value| [name, value] }
        else
          data['values'].map! { |time, value| [time, value] }
        end
        data
      end

      def strf_to_precision(start)
        case @time_precision
        when 'm'
          Time.at(start.to_f * 1000).strftime('%FT%T.%6NZ')
        when 's'
          Time.at(start.to_f).strftime('%FT%T.%6NZ')
        when 'ms'
          Time.at(start.to_f / 1000).strftime('%FT%T.%6NZ')
        when 'u'
          Time.at(start.to_f / 1000000).strftime('%FT%T.%6NZ')
        when 'ns'
          Time.at(start.to_f / 1000000000).strftime('%FT%T.%6NZ')
        end
      end

    end
  end
end
