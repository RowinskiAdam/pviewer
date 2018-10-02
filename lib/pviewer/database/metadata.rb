require 'yaml'

module PViewer
  module Database
    # Metadata is a class for managing metadata.
    # Handles with string, array, and hash.
    class Metadata
      def initialize(file_name)
        @file_name = file_name
        load_data
      end

      def add(series)
        @content.deep_merge_pv!(build_meta_hash(series))
        overwrite_file(@content.to_yaml)
        load_data
        read(series)
      end

      def read(series)
        read_content(series)
      end

      private

      def load_data
        open_file
        @content = YAML.safe_load(@file.read) || {}
        @file.close
      end

      def open_file(mode = 'a+')
        @file = File.open(File.join(path_to_file, full_file_name), mode)
      rescue Errno::ENOENT
        raise FileReadError, full_file_name
      end

      def path_to_file
        File.join(File.dirname(__FILE__), +'metadata')
      end

      def full_file_name
        @file_name + '.yml'
      end

      def build_meta_hash(series)
        metadata = series.metadata
        text = metadata.respond_to?(:each) ? unpack(metadata) : metadata

        { series.database => { series.measurement => text } }
      end

      def unpack(object)
        if object.is_a?(Array)
          object.join("\n")
        elsif object.is_a?(Hash)
          object.map { |e, v| e.to_s + ': ' + v.to_s }.join("\n")
        end
      end

      def overwrite_file(yaml)
        file = open_file('w+')
        file.write(yaml)
        file.close
      end

      def read_content(series)
        @content[series.database][series.measurement]
      rescue NoMethodError
        nil
      end
    end
  end
end
