module PViewer
  module Web
    module Commands
      # Intended to reading schema from database.
      class ReadScheme < Basic
        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          database: String,
          measurement: String,
          tag: String
        ).freeze

        RESPONSE_COMMAND = :display_scheme

        def execute(client:, database:, **_args)
          scheme = database.scheme(arguments)
          response = { details: arguments, data: scheme }
          command = Command.new(RESPONSE_COMMAND, response)

          client.send(Message.new([command]))
        end

      end
    end
  end
end
