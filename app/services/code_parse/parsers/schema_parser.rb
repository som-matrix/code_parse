module CodeParse
  module Parsers
    class SchemaParser
      def parse
        parse_schema(Rails.root.join("db/schema.rb"))
      end

      private

      def parse_schema(file)
        # Get the source code from the model file
        buffer = Parser::Source::Buffer.new(file)
        buffer.source = File.read(file)

        # Parses them into an ast (Abstract Syntax Tree)
        ast = Parser::Ruby33.new.parse(buffer)
        return unless ast

        # Pass the ast to to a model vistor/extractor which deals with these ast
        extractor = SchemaExtractor.new
        extractor.process(ast)

        {
          file: relative_path(file),
          tables: extractor.tables
        }
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
