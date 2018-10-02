module PViewer
  module Web
    # Web server config struct
    class Config
      DEFAULT_CONFIG_OPTIONS = {
        host: 'localhost',
        port: 3000,
        daemonize: true,
        logging: true,
        threaded: false
      }.freeze

      attr_accessor :host, :port, :daemonize, :logging, :threaded

      def initialize(**opts)
        DEFAULT_CONFIG_OPTIONS.each do |name, value|
          instance_variable_set "@#{name}", opts.fetch(name, value)
        end
      end
    end
  end
end
