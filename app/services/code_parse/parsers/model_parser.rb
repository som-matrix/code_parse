module CodeParse
  module Parsers
    class ModelParser
      def parse
        models.map { |file| parse_model(file) }.compact
      end

      private

      def models
        # Get all the model files from model directories
        Dir[Rails.root.join("app/models/**/*.rb")]
      end

      def parse_model(file)
        # Get the source code from the model file
        buffer = Parser::Source::Buffer.new(file)
        buffer.source = File.read(file)

        # Parses them into an ast (Abstract Syntax Tree)
        ast = Parser::Ruby33.new.parse(buffer)
        return unless ast

        # Pass the ast to to a model vistor/extractor which deals with these ast
        extractor = ModelExtractor.new
        extractor.process(ast)

        extractor.result.merge(
          file: relative_path(file)
        )
      rescue => e
        {
          file: relative_path(file),
          error: e.message
        }
      end

      def relative_path(path)
        path.sub(Rails.root.to_s, "")
      end
    end
  end
end
