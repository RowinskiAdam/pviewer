require 'set'
require_relative 'client'
require_relative 'command'
require_relative 'message'

module PViewer
  module Web
    # App(Application) should work on server and manage calls.
    class App
      def initialize(config, database)
        @resources = {
          app: self,
          database: database,
          config: config,
          clients: []
        }
        @gui = File.read(File.join(File.dirname(__FILE__), '/gui/index.html'))
      end

      def call(env)
        Faye::WebSocket.websocket?(env) ? create_new_client(env) : index_page
      end

      def execute(client, command)
        command.execute(@resources.merge(client: client))
      end

      def info
        { version: PViewer::VERSION, multithread: @resources[:config].threaded }
      end

      def remove_client(client)
        @resources[:clients].delete(client)
      end

      private

      def create_new_client(env)
        @resources[:clients] << client = Client.new(self, env)
        client.rack_response
      end

      def index_page
        [200, { 'Content-Type' => 'text/html' }, @gui]
      end
    end
  end
end
