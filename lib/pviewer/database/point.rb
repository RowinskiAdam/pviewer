module PViewer
  module Database
    # Default point object.
    class Point
      attr_reader :series, :tags, :time, :hash
      attr_accessor :values

      def initialize(series, values, tags: nil, time: nil)
        @series = series
        @values = values
        @tags = tags
        @time = time
        @hash = generate_hash
      end

      def ==(other)
        hash == other.hash
      end

      def merge!(other)
        values.merge!(other.values) do |key, old, new|
          next old if key.to_s.start_with?('~~')
          old = [old] unless old.respond_to? :each
          (new.is_a?(Array) ? (old + new) : (old << new)).uniq
        end
      end

      def process
        self.values = yield values
      end

      private

      def generate_hash
        tags = @tags.nil? ? nil : @tags.except('$index')
        [@series, tags, @time].hash
      end
    end
  end
end
