require_relative 'commands/basic'
Dir["#{File.dirname(__FILE__)}/commands/**/*.rb"].each { |file| require file }

module PViewer
  module Web
    # Used as command factory.
    # New commands added to commands/**/ dir will be required automatically.
    class Command
      COMMANDS_MODULE = PViewer::Web::Commands

      def self.new(name, **args)
        name = Command.snake_to_camel_notation(name)
        raise UnknownCommand, name unless Command.command_exists?(name)
        const_get(COMMANDS_MODULE.to_s + '::' + name.to_s).new(args)
        # rescue PViewer::InvalidArgumentFormat => e
        # Commands::Log.new(type: :error, message: e.message)
      end

      def self.command_exists?(name)
        COMMANDS_MODULE.const_defined?(name.to_s)
      rescue NameError
        raise UnknownCommand, name
      end

      def self.camel_to_snake_notation(string)
        string.gsub(/::/, '/')
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .tr('-', '_')
              .downcase
      end

      def self.snake_to_camel_notation(string)
        string.to_s.split('_').collect(&:capitalize).join
      end
    end
  end
end
