require 'influxdb'
require_relative 'influxQL/data'
require_relative 'influxQL/scheme'
require_relative '../../errors'

module PViewer
  module Database
    module Clients
      # Database client based on Influx-ruby gem.
      class Influx
        def initialize(**opts)
          opts[:database] ||= '"default"'
          opts[:time_precision] ||= 'u'
          opts[:retry] ||= 4
          opts[:denormalize] = false
          opts[:async] = { sleep_interval: 0.5 } if opts[:async].nil?

          @db = InfluxDB::Client.new opts
          try_connect
        end

        def to_s
          'InfluxDB powered by influxdb-ruby gem.'
        end

        def write(data, **opts)
          response = @db.write_points(unpack_points(data), opts[:precision],
                                      opts[:retention], opts[:database])
          response.code == 204 unless @db.config.async
        rescue InfluxDB::Error => e
          try_create_database_and_write(data, opts, e)
        end

        def exists?(name)
          scheme.include?(name)
        end

        def scheme(**opts)
          influx_ql = InfluxQL::Scheme.new(opts)
          data = @db.query(influx_ql.to_s, database: influx_ql.database).first

          return [] if data.nil?

          response = data['values'].flatten
          response.reject! { |e| e.start_with?('$') || e == 'type' }

          influx_ql.tag ? response.remove_every(2, 1) : response
        end

        def read(series, **opts)
          influx_ql = InfluxQL::Data.new(series.to_h)
          @db.query(influx_ql.to_s, opts)
        end

        def database_name=(name)
          @db.config.database = name
        end

        def database_name
          @db.config.database
        end

        def drop_measurement(database:, measurement:)
          @db.query "DROP MEASUREMENT \"#{measurement}\"", database: database
        end

        def async?
          @db.config.async != false
        end

        private

        def try_connect
          create(database_name)
        rescue InfluxDB::ConnectionError
          abort 'Cannot connect with database.'
        end

        def create(name)
          @db.create_database(name)
        end

        def unpack_points(data)
          data.map do |e|
            {
              series: e.series,
              values: e.values,
              tags: e.tags,
              timestamp: e.time
            }.compact
          end
        end

        def try_create_database_and_write(data, opts, error)
          raise WriteError, error if exists?(opts[:database] || database_name)
          create(opts[:database] || database_name)
          write(data, opts)
        end
      end
    end
  end
end
