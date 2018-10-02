module PViewer
  module Web
    module Commands
      class DisplayScheme < Basic
        REQUIRED_ARGS = [
          *REQUIRED_ARGS,
          :data,
          :details
        ].freeze

        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          details: Hash,
          data: Array
        ).freeze
      end
    end
  end
end
