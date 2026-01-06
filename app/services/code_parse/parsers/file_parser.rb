module CodeParse
  module Parsers
    class FileParser
      def initialize(type)
        @type = type
      end

      def parse
        files.map { |file| parse_file(file) }.compact
      end

      private

      def files
        case @type
        when "controller"
          Dir[Rails.root.join("app/controllers/**/*.rb")]
        when "model"
          Dir[Rails.root.join("app/models/**/*.rb")]
        when "view"
          Dir[Rails.root.join("app/views/**/*.rb")]
        else
          []
        end
      end

      def parse_file(file)
        buffer = Parser::Source::Buffer.new(file)
        buffer.source = File.read(file)

        parser = Parser::Ruby33.new
        ast = parser.parse(buffer)
        return unless ast

        extractor =
          case @type
          when "controller" then ControllerExtractor.new
          when "model"      then ModelExtractor.new
          when "view"       then ViewExtractor.new
          end

        extractor.process(ast)
        extractor.result.merge(file: relative_path(file))
      rescue => e
        { file: relative_path(file), error: e.message }
      end

      def relative_path(path)
        path.sub(Rails.root.to_s, "")
      end
    end
  end
end
