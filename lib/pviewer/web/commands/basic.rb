require_relative '../../errors'

module PViewer
  module Web
    module Commands
      # Used as abstract class, ensure basic methods and validations.
      #
      # Example:
      #
      # class ConsoleLogger < Basic
      #   ALLOWED_ARGS = ALLOWED_ARGS.merge(
      #     message: String
      #   )
      #
      #   def execute(**args)
      #     puts "Executed with arguments #{arguments}"
      #   end
      #
      # end
      #
      class Basic
        # rubocop: disable Style/MutableConstant
        REQUIRED_ARGS = []
        ALLOWED_ARGS = {}
        # rubocop: enable Style/MutableConstant

        def initialize(**args)
          self.arguments = args
          raise ArgumentMissing, @missing_args.join(', ') if missing_args?
        end

        def to_h
          { command: name }.merge(arguments: arguments)
        end

        def name
          Command.camel_to_snake_notation(self_class_name)
        end

        def arguments
          attributes.keep_if do |key, value|
            !value.nil? && allowed_arg?(key)
          end
        end

        def response_command
          self.class::RESPONSE_COMMAND if defined? self.class::RESPONSE_COMMAND
        end

        def execute(*)
          raise AbstractMethod
        end

        private

        def missing_args?
          attrs = attributes

          @missing_args = self.class::REQUIRED_ARGS.dup.keep_if do |name|
            attrs[name].nil?
          end

          !@missing_args.empty?
        end

        def arguments=(args)
          self.class::ALLOWED_ARGS.each do |attr, _type|
            raise InvalidType, attr unless correct_type?(attr, args[attr])
            instance_variable_set("@#{attr}", args[attr])
          end
        end

        def correct_type?(attr, arg_val)
          return true if arg_val.nil?
          arg_val.is_a?(self.class::ALLOWED_ARGS[attr.to_sym])
        end

        def self_class_name
          self.class.name.to_s.gsub(/^.*::/, '')
        end

        def attributes
          attrs = instance_variables.map do |ivar|
            value = instance_variable_get(ivar)
            [ivar[1..-1].to_sym, value]
          end.compact.to_h

          attrs.empty? ? {} : attrs
        end

        def allowed_arg?(arg)
          self.class::ALLOWED_ARGS.keys.include?(arg.to_sym)
        end
      end
    end
  end
end
