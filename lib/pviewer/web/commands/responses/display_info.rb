module PViewer
  module Web
    module Commands
      class DisplayInfo < Basic
        REQUIRED_ARGS = [
          *REQUIRED_ARGS,
          :data
        ].freeze

        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          data: Hash, script: String
        ).freeze
      end
    end
  end
end
