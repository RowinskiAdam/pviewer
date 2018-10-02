module PViewer
  module Web
    module Commands
      # Get reduction methods
      class ReductionTypes < Basic

        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          methods: Array
        ).freeze

        def execute(client:, **_args)
          @methods = PViewer::Database::ReductionTypes.public_instance_methods

          client.send(Message.new([self]))
        end
      end
    end
  end
end
