require_relative 'basic'

module PViewer
  module Database
    module Clients
      module InfluxQL
        # Class for storing and manage influxQL for scheme exploration
        class Scheme < Basic
          ALLOWED_ARGS = %i[database measurement tag field].freeze

          attr_reader :tag

          def initialize(**args)
            super(args)
          end

          private

          SYNTAX_STRINGS = [
            'DATABASES',
            'MEASUREMENTS ON "%<database>s"',
            'TAG KEYS ON "%<database>s" FROM "%<measurement>s"',
            'TAG VALUES ON "%<database>s" FROM "%<measurement>s"' \
              ' WITH KEY = "%<tag>s"',
            'FIELD KEYS ON  "%<database>s" FROM "%<measurement>s"'
          ].freeze

          def define_syntax
            @syntax = 'SHOW ' + if @args.delete(:field)
                                  (SYNTAX_STRINGS[4] % @args)
                                else
                                  (SYNTAX_STRINGS[@args.length] % @args)
                                end
          end
        end
      end
    end
  end
end
