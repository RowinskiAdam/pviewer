module PViewer
  module Web
    module Commands
      # Intended to be used as a gui logger notifier.
      class Log < Basic
        REQUIRED_ARGS = [
          *REQUIRED_ARGS,
          :type,
          :message
        ].freeze

        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          type: Symbol,
          message: String
        ).freeze

        def execute(client:, **_args)
          client.send(Message.new([self]))
        end
      end
    end
  end
end
