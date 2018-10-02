Dir["#{File.dirname(__FILE__)}/clients/*.rb"].each { |file| require file }
require_relative 'metadata'
require_relative 'series'
require_relative 'series_reader'
require_relative 'event_reader'
require_relative 'series_writer'
require_relative 'event_writer'

module PViewer
  module Database
    # Intermediary class between the specified database client and the system.
    class Client
      @@writers = []
      attr_reader :measurement_name

      def initialize(name = nil, **opts)
        @client = new_client(name || opts[:driver] || 'Influx', opts)
        @metadata = Metadata.new(opts[:metadata_file] || 'metadata')
        @events_handlers_opts = { experiments: opts.delete(:experiments),
                                  metadata: opts.delete(:metadata) }
        @measurement_name = opts[:measurement]
      end

      def finalize(wait_time = 1.25)
        @@writers.each(&:finalize)
        sleep wait_time
      end

      def to_s
        @client.to_s
      end

      def write(data, **opts)
        @client.write(data, opts)
      end

      def exists?(name)
        @client.exists?(name)
      end

      def scheme(**opts)
        @client.scheme(opts)
      end

      def read(series, **opts)
        @client.read(series, **opts)
      end

      def database_name=(name)
        @client.database_name = name
      end

      def database_name
        @client.database_name
      end

      def info
        {
            driver: @client.class.name.to_s.gsub(/^.*::/, ''),
            async: @client.async?
        }
      end

      def series_writer(**args, &block)
        SeriesWriter.new(args.merge(db_client: self), &block)
      end

      def series_reader(**args, &block)
        SeriesReader.new(args.merge(db_client: self), &block)
      end

      def event_writer(**args, &block)
        args[:db_client] = self
        args.merge!(@events_handlers_opts)

        EventWriter.new(args, &block)
      end

      def event_reader(**args, &block)
        EventReader.new(args.merge(db_client: self), &block)
      end

      def metadata(series)
        @metadata.read(series)
      end

      def metadata=(series)
        @metadata.add(series)
      end

      def drop_measurement(**args)
        @client.drop_measurement(**args)
      end

      def writers
        @@writers
      end

      private

      def new_client(client, opts)
        PViewer::Database::Clients.const_get(client.capitalize.to_s).new(opts)
      rescue NameError
        raise UnknownClient, client
      end
    end
  end
end
