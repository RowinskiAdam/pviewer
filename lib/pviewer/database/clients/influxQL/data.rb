require_relative 'basic'
require_relative '../../../errors'

module PViewer
  module Database
    module Clients
      module InfluxQL
        # Class for storing and manage influxQL for data exploration
        # Allows to update time in syntax string.
        class Data < Basic
          ALLOWED_ARGS = %i[database measurement tags selector subquery
                            time group_by aggregate_function].freeze

          AGGREGATE_FUNCTIONS = %w[MIN MEAN MAX MEDIAN
                                   SUM MODE STDDEV SPREAD].freeze

          def initialize(**args)
            super(args)
          end

          def to_s
            @syntax + @syntax_time.to_s + @syntax_group_by.to_s
          end

          def update_time(time)
            @time = time
            specify_time
            self
          end

          private

          def define_syntax
            raise_unless_necessary_args

            selector = generate_selector || '*::field'

            @syntax = "SELECT #{selector} FROM "

            add_measurements
            add_where_clause
          end

          def generate_selector
            selector = selector? ? @selector.to_s : nil
            if aggregate_function?
              "#{@aggregate_function}(#{selector || '*'})"
            else
              selector
            end
          end

          def add_measurements
            @syntax << if @args[:measurement].is_a?(Array)
                         "\"#{database}\"..\"#{measurement.join('", "')}\""
                       else
                         "\"#{database}\"..\"#{measurement}\""
                       end
          end

          def add_where_clause
            add_tags if tags?
            specify_time if time?
            add_group_by if group_by?
          end

          def raise_unless_necessary_args
            ALLOWED_ARGS.slice(0, 2).each do |arg|
              raise ArgumentError, "Argument #{arg} is missing." unless @args[arg]
            end
          end

          def tags?
            @tags && @tags.respond_to?(:each) && !@tags.empty?
          end

          def add_tags
            @syntax << ' WHERE '
            @tags.each_with_index do |(key, value), i|
              @syntax << (' and ' if i > 0).to_s
              if value.is_a?(Array)
                add_tags_from_array(key, value)
              else
                @syntax << "\"#{key}\" " + operator_and_value(value)
              end
            end
          end

          def add_tags_from_array(key, value)
            @syntax << '(' if value.length > 1

            value.each_with_index do |av, j|
              @syntax << (' or ' if j > 0).to_s
              @syntax << "\"#{key}\" " + operator_and_value(av)
            end

            @syntax << ')' if value.length > 1
          end

          def operator_and_value(value)
            value.is_a?(Regexp) ? "=~ #{value.inspect}" : "= '#{value}'"
          end

          def time?
            !@time.nil?
          end

          def specify_time
            time_part = @time.is_a?(Numeric) ? '%<time>s' : "'%<time>s'"

            opts = { clause: tags? ? 'and' : 'WHERE', time: @time }

            @syntax_time = '' << format(' %<clause>s time > ' + time_part, opts)
          end

          def group_by?
            !@group_by.nil?
          end

          def aggregate_function?
            AGGREGATE_FUNCTIONS.include?(@aggregate_function)
          end

          def subquery?
            !@args[:subquery].nil?
          end

          def add_group_by
            time = @args[:group_by].match?(/time\([0-9]+[smhd]\)/)
            group_by = time ? "'#{@args[:group_by]}'" : "\"#{@args[:group_by]}\""
            @syntax_group_by = " GROUP BY #{group_by}"
          end

          def selector?
            !@selector.nil?
          end
        end
      end
    end
  end
end