module PViewer
  module Web
    module Commands
      # ReadData is a command intended to read data from database
      # and send to client. If is continuous series, it adds continuous job
      # that fetching data from database and send it to client
      # in specified intervals.
      class ReadData < Basic
        REQUIRED_ARGS = [
          *REQUIRED_ARGS,
          :database,
          :measurement
        ].freeze

        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          database: String,
          measurement: String,
          tags: Hash,
          group_by: String,
          aggregate_function: String,
          reduce_type: String,
          gui_format: String,
          time_precision: String
        ).freeze

        RESPONSE_COMMAND = :display_data

        def execute(client:, database:, **_args)
          reader = database.event_reader(arguments)
          data = reader.read

          command = Command.new(RESPONSE_COMMAND, data: data)
          client.send(Message.new([command]))
          #client.add_reader(reader)
        end

      end
    end
  end
end
