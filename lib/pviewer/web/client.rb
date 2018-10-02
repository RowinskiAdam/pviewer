require 'faye/websocket'

module PViewer
  module Web
    # Client is a class for managing single web socket connection with server.
    # Passes messages sent through web socket to app#execute.
    # Stores readers in array.
    class Client
      attr_accessor :readers

      def initialize(app, env)
        @app = app
        @socket = Faye::WebSocket.new(env, nil, ping: 25)
        register_events
      end

      def rack_response
        @socket.rack_response
      end

      def send(message)
        @socket.send(message.to_json)
      rescue NoMethodError
        false
      end

      private

      def register_events
        @socket.on :message do |event|
          Message.new(event.data).commands.each do |cmd|
            @app.execute(self, cmd)
          end
        end
        @socket.on :close do |_event|
          @app.remove_client(self)
          @socket = nil
        end
      end
    end
  end
end
