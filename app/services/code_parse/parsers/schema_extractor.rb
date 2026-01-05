module CodeParse
  module Parsers
    class SchemaExtractor < Parser::AST::Processor
      def initialize
        @tables = {}
        @current_table = nil
        @current_t_var = nil
      end

      attr_reader :tables

      # === BLOCK HANDLING ===
      # Handles:
      # create_table "users" do |t|
      #   ...
      # end
      def on_block(node)
        send_node, args_node, body = *node

        if create_table_block?(send_node, args_node)
          table_name = extract_table_name(send_node)
          t_var = extract_t_var(args_node)

          @current_table = {
            columns: [],
            indexes: []
          }

          @tables[table_name] = @current_table
          @current_t_var = t_var

          process(body)

          @current_table = nil
          @current_t_var = nil
          return
        end

        super
      end

      # === SEND HANDLING ===
      # Handles:
      # t.string "name", null: false
      # t.index ["user_id"], unique: true
      def on_send(node)
        receiver, method_name, *args = *node

        return super unless inside_table_block?(receiver)

        case method_name
        when :string, :text, :integer, :bigint, :float,
             :decimal, :boolean, :datetime, :date, :time
          add_column(method_name, args)

        when :index
          add_index(args)
        end

        super
      end

      private

      # -------------------------
      # Block helpers
      # -------------------------

      def create_table_block?(send_node, args_node)
        send_node&.type == :send &&
          send_node.children[1] == :create_table &&
          args_node&.type == :args
      end

      def extract_table_name(send_node)
        send_node.children[2].children.first
      end

      def extract_t_var(args_node)
        return unless args_node&.type == :args

        arg = args_node.children.first
        return unless arg

        case arg.type
        when :arg
          arg.children.first
        when :procarg0
          arg.children.first.children.first
        end
      end

      def inside_table_block?(receiver)
        return false unless @current_table

        case receiver&.type
        when :lvar
          receiver.children.first == @current_t_var
        when :send
          receiver.children.last == @current_t_var
        else
         false
        end
      end

      # -------------------------
      # Column handling
      # -------------------------

      def add_column(type, args)
        name_node = args[0]
        options_node = args[1]

        @current_table[:columns] << {
          name: literal_value(name_node),
          type: type
        }.merge(extract_kwargs(options_node))
      end

      # -------------------------
      # Index handling
      # -------------------------

      def add_index(args)
        columns_node = args[0]
        options_node = args[1]

        columns =
          if columns_node.type == :array
            columns_node.children.map { |n| literal_value(n) }
          else
            [ literal_value(columns_node) ]
          end

        @current_table[:indexes] << {
          columns: columns
        }.merge(extract_kwargs(options_node))
      end

      # -------------------------
      # Keyword arguments
      # -------------------------

      def extract_kwargs(node)
        return {} unless node&.type == :kwargs

        node.children.each_with_object({}) do |pair, hash|
          key = pair.children[0].children.first
          value = literal_value(pair.children[1])
          hash[key] = value
        end
      end

      # -------------------------
      # Literal extraction
      # -------------------------

      def literal_value(node)
        return unless node.is_a?(Parser::AST::Node)

        case node.type
        when :str, :sym, :int, :float
          node.children.first
        when :true
          true
        when :false
          false
        else
          nil
        end
      end
    end
  end
end
