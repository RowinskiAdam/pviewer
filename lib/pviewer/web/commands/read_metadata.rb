module PViewer
  module Web
    module Commands
      # Intended to reading metadata.
      class ReadMetadata < Basic
        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          database: String,
          measurement: String
        ).freeze

        RESPONSE_COMMAND = :display_metadata

        def execute(client:, database:, **_args)
          series = PViewer::Database::Series.new(arguments)
          metadata = database.metadata(series)
          command = Command.new(RESPONSE_COMMAND, data: metadata,
                                                  measurement: @measurement)

          client.send(Message.new([command]))
        end
      end
    end
  end
end
