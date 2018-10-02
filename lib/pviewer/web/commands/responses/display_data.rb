module PViewer
  module Web
    module Commands
      class DisplayData < Basic
        ALLOWED_ARGS = ALLOWED_ARGS.merge(
          data: Array
        ).freeze
      end
    end
  end
end
