require "set"

module Parzer
  module Lr_Zero
    def self.define_syntax(&block)
      context = Context.new
      block.call(context)
      context.syntax_definition_completed

      return context
    end

    # Context where syntax is defined
    class Context
      def initialize
        @tokens = {}
        @n_tokens = {}
        @raw_rules = []
        @rules = []
        @token_id = 1
        @n_token_id = 1
        @rule_id = 1
        @syntax_definition_completed = false

        token("$")
      end

      # DSL for define (terminal) token
      def token(name)
        ensure_syntax_definition_not_completed!

        name = name.to_sym

        raise "Token is duplicated: #{name}" if fetch_token(name)

        terminal = Terminal.new(@token_id, name)
        @tokens[name] = terminal
        @token_id += 1
        terminal
      end

      # DSL for define rule
      def rule(lhs, *rhs)
        ensure_syntax_definition_not_completed!

        @raw_rules << [lhs, rhs]
      end

      def syntax_definition_completed
        return if @syntax_definition_completed

        build_rules
        @syntax_definition_completed = true
      end

      def rules
        raise "You should complete to define syntax" unless @syntax_definition_completed
        @rules
      end

      # "*X" form
      def stations
        ensure_syntax_definition_completed!

        @n_tokens.map do |_, t|
          ["*", t.name]
        end
      end

      # Rules with "*"
      def items
        ensure_syntax_definition_completed!

        @rules.flat_map do |rule|
          (0..(rule.right_tokens.count)).map do |i|
            RuleWithPos.new(rule, i)
          end
        end
      end

      def construct_parse_table
        ensure_syntax_definition_completed!

        # a list of pairs of states (item sets) and numbers, called S
        s = []
        # a set of transitions T
        t = Set.new
        # a list U of numbers of new, unprocessed LR states
        u = []

        # Start with "*A" where "A" is the start symbol
        station = stations.first
      end

      private

      def build_rules
        ensure_syntax_definition_not_completed!

        # Build Nonterminals
        @raw_rules.each do |lhs, _|
          fetch_or_create_n_token(lhs)
        end

        @raw_rules.each do |lhs, rhss|
          left_token = fetch_n_token!(lhs)
          right_tokens = rhss.map do |name|
            fetch_token(name) || fetch_n_token(name) || (raise "\"#{name}\" is not found.")
          end
          rule = Rule.new(@rule_id, left_token, right_tokens)
          @rules << rule 
          @rule_id += 1
        end
      end

      def ensure_syntax_definition_not_completed!
        raise "You can not change syntax once definition completed." if @syntax_definition_completed
      end

      def ensure_syntax_definition_completed!
        raise "You should complete syntax definition." if !@syntax_definition_completed
      end

      def fetch_or_create_n_token(name)
        name = name.to_sym
        token = @n_tokens[name]
        return token if token

        nonterminal = Nonterminal.new(@n_token_id, name)
        @n_tokens[name] = nonterminal
        @n_token_id += 1
        nonterminal
      end

      def fetch_token(name)
        @tokens[name.to_sym]
      end

      def fetch_token!(name)
        token = fetch_token(name)
        raise "Unknown token is required: #{name}" if token.nil?
        return token
      end

      def fetch_n_token(name)
        @n_tokens[name.to_sym]
      end

      def fetch_n_token!(name)
        n_token = fetch_n_token(name)
        raise "Unknown n_token is required: #{name}" if n_token.nil?
        return n_token
      end
    end

    class Rule
      attr_reader :id, :left_token, :right_tokens

      def initialize(id, left_token, right_tokens)
        @id = id
        @left_token = left_token
        @right_tokens = right_tokens
      end
    end

    # "*A" where "*" is pos
    class RuleWithPos
      def initialize(rule, pos_index)
        @rule = rule
        @pos_index = pos_index
      end

      def as_array
        [@rule.id, @rule.left_token.name, @rule.right_tokens.map(&:name).insert(@pos_index, "*")]
      end

      def to_s
        as_array.to_s
      end

      alias inspect to_s
    end

    class Terminal
      attr_reader :name

      def initialize(id, name)
        @id = id
        @name = name
      end

      def to_s
        "\"#{@name}\" (#{@id})"
      end

      alias inspect to_s
    end

    class Nonterminal
      attr_reader :name

      def initialize(id, name)
        @id = id
        @name = name
      end

      def to_s
        "\"#{@name}\" (#{@id})"
      end

      alias inspect to_s
    end
  end
end
