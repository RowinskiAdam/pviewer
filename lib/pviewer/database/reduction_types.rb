module PViewer
  module Database
    # Methods used to array reduction.
    module ReductionTypes
      def sum(value)
        value.reduce(:+)
      end

      def mean(value)
        value.inject { |sum, el| sum + el }.to_f / value.size
      end

      def first(value)
        value.first
      end

      def last(value)
        value.last
      end

      def max(value)
        value.max
      end

      def min(value)
        value.min
      end
    end
  end
end
