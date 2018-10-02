require 'time'
require_relative '../../../errors'

module PViewer
  module Database
    module Clients
      module InfluxQL
        # Basic Exploration Syntax class intended for inheriting from it.
        class Basic
          attr_reader :database, :measurement

          def initialize(**args)
            @args = args
            add_valid_args_as_ivar
            define_syntax
          end

          def to_s
            @syntax
          end

          private

          def add_valid_args_as_ivar
            validate_args
            add_args_as_ivar
          end

          def validate_args
            @args.keep_if { |key, _| self.class::ALLOWED_ARGS.include?(key) }
          end

          def add_args_as_ivar
            self.class::ALLOWED_ARGS.each do |value|
              instance_variable_set("@#{value}", @args[value])
            end
          end

          def define_syntax
            raise AbstractMethod, __method__.to_s
          end
        end
      end
    end
  end
end
