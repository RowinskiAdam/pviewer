module PViewer
  module Web
    # Message:
    # Used to exchange information between GUI and server,
    # stores commands and parsing them to the appropriate format.
    # Could be initialized by json as string or array with commands.
    class Message
      attr_accessor :commands

      # rubocop:disable Lint/ReturnInVoidContext
      def initialize(args = {})
        return @commands = args if args.is_a?(Array)
        @commands = []
        args = json_parse(args) if args.is_a?(String)
        create_commands(args[:commands]) unless args.empty?
      rescue JSON::ParserError
        self_to_error('Invalid JSON.')
      end
      # rubocop:enable Lint/ReturnInVoidContext

      def to_h
        { commands: commands.map(&:to_h) }
      end

      def to_json
        to_h.to_json
      end

      private

      def json_parse(args)
        JSON.parse(args, symbolize_names: true)
      end

      def create_commands(commands)
        commands.each do |command|
          command[:arguments] ||= {}
          @commands.push(
            Command.new(command[:name], prepare_arguments(command[:arguments]))
          )
        end
        @commands.flatten!
      end

      def prepare_arguments(args)
        reject_empty(args)
        parse_numbers(args)
        args
      end

      def reject_empty(args)
        return nil if args.nil?
        args.reject! { |_, v| v.nil? || v.empty? }
      end

      def self_to_error(message)
        @commands.push(Command.new(:log, type: :error, message: message))
      end

      def parse_numbers(args)
        args[:resample] = to_f_or_i_or_s(args[:resample])
      end

      def to_f_or_i_or_s(value)
        ((float = Float(value)) && (float % 1.0).zero? ? float.to_i : float)
      rescue StandardError
        value
      end
    end
  end
end
