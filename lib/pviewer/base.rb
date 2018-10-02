require_relative 'database/client'
require_relative 'handler/counters'
require_relative 'handler/durations'
require_relative 'handler/values'
require_relative 'web/app'
require_relative 'web/config'
require_relative 'web/server'

module PViewer
  # Basic PViewer class, combines gui with database.
  # Stores @database client, @application that is running on @server.
  # Allows to create different kind of events handler.
  class Base
    def initialize(db_conf = {}, app_conf = {})
      config = Web::Config.new(app_conf)

      @database = Database::Client.new(db_conf)

      save_buffers_on_kill unless db_conf[:disable_save_on_kill]
      return unless app_conf[:gui]
      @app = Web::App.new(config, @database)
      @server = Web::Server.new(config, @app)
      @server.start
    end

    def durations_handler(**args)
      args[:db_client] = @database
      Handler::Durations.new(**args)
    end

    def values_handler(**args)
      args[:db_client] = @database
      Handler::Values.new(**args)
    end

    def counters_handler(**args)
      args[:db_client] = @database
      Handler::Counters.new(**args)
    end

    def run_gui(**args)
      return false if gui_running?
      if @server.nil?
        args[:daemonize] ||= false
        config = Web::Config.new(**args)
        @app = Web::App.new(config, @database)
        @server = Web::Server.new(config, @app)
      end
      @server.start
    end

    def finalize
      @database.finalize
    end

    private

    def gui_running?
      @server && @server.running?
    end

    def save_buffers_on_kill
      Thread.new do
        begin
          Thread.stop
        ensure
          finalize
        end
      end
    end

  end
end
