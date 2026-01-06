module CodeParse
  module Parsers
    class ControllerExtractor < Parser::AST::Processor
      def initialize
        @inside_private = false
        @namespace_stack = []
        @result = {
          name: nil,
          namespace: nil,
          parent: nil,
          actions: [],
          private_methods: []
        }
      end

      attr_reader :result

      def on_module(node)
        name_node, body = *node
        name = const_name(name_node)
        @namespace_stack << name if name
        process(body) if body
        @namespace_stack.pop
        @result[:namespace] = @namespace_stack.join("::") if @namespace_stack.any?
      end

      def on_class(node)
        class_name, parent_class, body = *node
        full = const_name(class_name)
        @result[:name] = full.split("::").last
        @result[:namespace] = full.deconstantize.presence
        @result[:parent] = const_name(parent_class)
        process(body) if body
      end

      def on_send(node)
        receiver, method_name, *args = *node
        if method_name == :private
          @inside_private = true
        end
        super
      end

      def on_def(node)
        method_name, _args, body = *node

        if @inside_private
          @result[:private_methods] << method_name
        else
          @result[:actions] << method_name
        end

        process(body) if body
      end

      private

      def const_name(node)
        return nil unless node.is_a?(Parser::AST::Node) && node.type == :const
        parts = []
        while node&.type == :const
          parts.unshift(node.children.last.to_s)
          node = node.children.first
        end
        parts.join("::")
      end
    end
  end
end
