module PViewer
  module Web
    module Commands
      class DisplayMetadata < Basic
        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          measurement: String,
          data: String
        ).freeze
      end
    end
  end
end
