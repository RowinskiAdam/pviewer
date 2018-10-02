module PViewer
  module Web
    module Commands
      # Intended to reading info about app and database.
      class ReadInfo < Basic
        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          info: Hash
        ).freeze

        RESPONSE_COMMAND = :display_info

        def execute(client:, app:, database:, **_args)
          information = { application: app.info, database: database.info }
          info_cmd = Command.new(RESPONSE_COMMAND, data: information)

          client.send(Message.new([info_cmd]))
        end
      end
    end
  end
end
