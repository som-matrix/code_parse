module CodeParse
  module Parsers
    class ModelExtractor < Parser::AST::Processor
      def initialize
        @result = {
          name: nil,
          associations: [],
          validations: [],
          callbacks: [],
          scopes: [],
          enums: [],
          instance_methods: [],
          class_methods: [],
          concerns: []
        }
      end

      attr_reader :result

      def on_class(node)
        class_name, _, body = *node
        @result[:name] = symbol_name(class_name)
        process(body) if body
      end

      def on_send(node)
        receiver, method_name, *args = *node

        return super unless receiver.nil?

        case method_name
        when :include, :extend, :prepend
          args.each do |arg|
          name = symbol_name(arg)
          @result[:concerns] << name if name
          end
        when :belongs_to, :has_one, :has_many, :has_and_belongs_to_many
          @result[:associations] << symbol_name(args.first)
        when :validates
          @result[:validations] << symbol_name(args.first)
        when :before_validation, :after_validation, :before_save, :around_save, :before_create, :around_create, :after_create, :after_save, :after_commit, :after_rollback
          @result[:callbacks] << method_name
        when :scope
          @result[:scopes] << symbol_name(args.first)
        when :enum
          @result[:enums] << symbol_name(args.first)
        end

        super
      end

      def on_def(node)
        name, = *node
        @result[:instance_methods] << name
      end

      def on_defs(node)
        _, name, = *node
        @result[:class_methods] << name
      end

      private

      def symbol_name(node)
        return unless node.is_a?(Parser::AST::Node)

        case node.type
        when :const
          parent, name = *node
          if parent
            parent_name = symbol_name(parent)
            parent_name ? "#{parent_name}::#{name}" : name.to_s
          else
            name.to_s
          end
        when :sym
          node.children.first
        when :str
          node.children.first.to_sym
        else
          nil
        end
      end
    end
  end
end
