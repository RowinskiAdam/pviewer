module PViewer
  # rubocop:disable Style/Documentation

  class Error < StandardError; end

  class AbstractMethod < Error
    def message
      format('%<message>s is intended to be used as abstract method.',
             message: exception.to_s)
    end
  end

  class InvalidType < Error
    def message
      format('%<message>s argument is invalid.',
             message: exception.to_s.capitalize)
    end
  end

  class UnknownCommand < Error
    def message
      format('%<message>s is not valid command.',
             message: exception.to_s.capitalize)
    end
  end

  module Database
    class DatabaseError < Error; end

    class ReadError < DatabaseError
      def message
        'Database error occured when trying to read data.'
      end
    end

    class WriteError < DatabaseError
      def message
        format('Database error occured when trying to write data. %<e>s',
               e: exception.to_s)
      end
    end

    class ConnectionError < DatabaseError
      def message(config = nil)
        message = 'Cannot connect with database.'
        return message if config
        message + " Tried on host: #{config.host} port: #{config.port}."
      end
    end

    class UnknownClient < DatabaseError
      def message
        format('Unknown client %<e>s', e: exception.to_s)
      end
    end

    class MissingClient < DatabaseError
      def message
        'Database client was not specified.'
      end
    end

    # File read error
    class FileReadError < Error
      def message
        format('Cannot read file %<message>.',
               message: exception.to_s)
      end
    end
  end

  module Web
    module Commands
      class ArgumentMissing < Error
        def message
          format('Command %<message>s arguments are missing.',
                 message: exception.to_s)
        end
      end
    end
  end

  # rubocop:enable Style/Documentation
end
