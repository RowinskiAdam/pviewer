require 'thin'

module PViewer
  module Web
    # Server class, using a Thin web server.
    #
    # Note:
    # Thin daemonize is not supported on windows. That is why using
    # standard new Thread.
    #
    class Server
      START_LOG = lambda { |config|
        puts "PerformanceViewer v.#{PViewer::VERSION} started.\n" \
             "Thin web server running on #{config.host}:#{config.port}."
      }

      def initialize(config, app)
        Faye::WebSocket.load_adapter('thin')
        @app = app
        @config = config
        @server = create_server
      end

      def start
        start_server
      end

      def stop
        @server.stop if @server
      end

      def stopped?
        @server.running?
      end

      private

      def create_server
        Thin::Logging.level = :warn

        app = @app
        Thin::Server.new(@config.host, @config.port) do
          use Rack::Static,
              urls: %w[/assets /assets/icons /assets/libraries],
              root: File.join(File.dirname(__FILE__), 'gui')
          # ,:index => 'index.html' # websocket handshake conflict, response 200
          run app
        end
      end

      def start_server
        START_LOG.call(@config) if @config.logging

        @server.threaded = true if @config.threaded
        # @server.daemonize = true if @config.daemonize
        @config.daemonize ? Thread.new { @server.start } : @server.start
      end
    end
  end
end
