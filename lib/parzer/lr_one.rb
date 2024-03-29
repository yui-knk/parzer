require "set"

module Parzer
  module Lr_One
    def self.define_syntax(&block)
      context = Context.new
      block.call(context)
      context.syntax_definition_completed

      return context
    end

    # Context where syntax is defined
    class Context
      attr_reader :tokens, :n_tokens

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
          Station.new(t)
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

        # "a list of pairs of states (item sets) and numbers, called S"
        # But here hash from state_id to states
        s = {}
        # a set of transitions T, [from (state), path (token), to (state)]
        t = Set.new
        # a list U of numbers of new, unprocessed LR states
        u = []
        state_id = 1

        # Start with [S -> *E, $] "S" is the start symbol
        r = @rules.first
        term = r.build_term(0, @tokens[:"$"])

        # Add states
        s[state_id] = build_state(term)
        u << state_id
        state_id += 1

        while !u.empty? do
          target_state_id = u.shift
          target_terms = s[target_state_id]

          all_tokens.each do |token|
            v = goto(target_terms, token)

            next if v.empty?

            if s.key(v)
              t << [target_state_id, token, s.key(v)]
            else
              # Add states
              s[state_id] = v
              u << state_id
              t << [target_state_id, token, state_id]
              state_id += 1
            end
          end
        end

        [s, t]
      end

      def all_tokens
        @tokens.values + @n_tokens.values
      end

      def action_goto_tables
        s, t = construct_parse_table

        action_table = []
        goto_table = []

        s.count.times do |i|
          action_table[i + 1] = []
          goto_table[i + 1] = []
        end

        s.each do |k, terms|
          terms.each do |term|
            # (2-c)
            if term.rule.id == 1 && term.rule_with_pos.dot_is_end?
              action_table[k][@tokens[:"$"].id] = :acc
              next
            end

            token = term.rule_with_pos.token_after_pos

            if !token.nil?
              # (2-a)
              next if token.is_nonterminal?

              state = goto(terms, token)
              action_table[k][token.id] = :"shift_#{s.key(state)}"
            else
              # (2-b)
              rule = term.rule
              next if rule.left_token.id == 1

              action_table[k][term.token.id] = :"reduce_#{rule.id}"
            end
          end

          @n_tokens.each do |k2, n_token|
            state = goto(terms, n_token)
            next if state.empty?

            goto_table[k][n_token.id] = s.key(state)
          end
        end

        return action_table, goto_table, s, t
      end

      def build_parser(lexer)
        action, goto, s, t = action_goto_tables
        Parser.new(action, goto, @tokens, @n_tokens, lexer, s, t)
      end

      # FIRST
      #
      # each token can be Terminal and Nonterminal
      def first(*tokens)
        ensure_syntax_definition_completed!

        result = Set.new
        token = tokens.first

        if token.is_terminal?
          result << token
        else
          @rules.select do |rule|
            (rule.left_token == token) && (rule.right_tokens.first != token)
          end.each do |rule|
            result.merge(first(rule.right_tokens.first))
          end
        end

        result
      end

      # FOLLOW
      #
      # https://knsm.net/follow-%E3%81%AE%E8%A8%88%E7%AE%97%E3%82%92%E9%96%93%E9%81%95%E3%81%88%E3%81%AB%E3%81%8F%E3%81%8F%E3%81%99%E3%82%8B%E5%B7%A5%E5%A4%AB-d1d978ce96ec
      def follow(n_token)
        ensure_syntax_definition_completed!

        result = Set.new

        if n_token == @n_tokens[:S]
          result << @tokens[:"$"]
          return result
        end

        # Find rules which include n_token in right hand side
        #
        # A -> αBβ  where B is n_token argument
        @rules.select do |rule|
          rule.right_tokens.any? {|t| t == n_token }
        end.each do |rule|
          i = rule.right_tokens.index(n_token)
          t = rule.right_tokens[i + 1]

          if t.nil?
            next if n_token == rule.left_token
            # n_token is the last
            result.merge(follow(rule.left_token))
          else
            next if n_token == t
            result.merge(first(t))
          end
        end

        result
      end

      def build_state(term)
        states = Set.new
        states << term
        expand_state(states)
        states
      end

      private

      # GOTO
      def goto(target_terms, token)
        v = Set.new
        target_terms.each do |term|
          rule_with_pos = term.rule_with_pos
          next if rule_with_pos.token_after_pos != token

          new_rule_with_pos = rule_with_pos.right_shift_pos
          v << new_rule_with_pos.build_term(term.token)
        end

        expand_state(v)

        v
      end

      def expand_state(states)
        added = false
        new_terms = []

        states.each do |term|
          token = term.rule_with_pos.token_after_pos

          @rules.select do |rule|
            rule.left_token == token
          end.each do |rule|
            tokens = term.rule_with_pos.tokens_after_pos

            first(*tokens, term.token).each do |t|
              new_terms << rule.build_term(0, t)
            end
          end
        end

        new_terms.each do |n|
          added ||= states.add?(n)
        end

        if added
          expand_state(states)
        end
      end

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

      def build_rule_with_pos(pos)
        RuleWithPos.new(self, pos)
      end

      # token is terminal
      def build_term(pos, token)
        Term.new(build_rule_with_pos(pos), token)
      end

      def ==(other)
        return false unless other.is_a?(Rule)

        (self.id == other.id) && (self.left_token == other.left_token) && (self.right_tokens == other.right_tokens)
      end
      alias :eql? :==

      def hash
        [id, left_token, right_tokens].hash
      end
    end

    # "*A" where "*" is pos
    class RuleWithPos
      attr_reader :rule, :pos_index
      # pos_index >= 0
      def initialize(rule, pos_index)
        raise "pos_index should not be negative: #{pos_index}." if pos_index < 0
        raise "pos_index should not be less than right_tokens count: #{rule.right_tokens.count}, #{pos_index}" if rule.right_tokens.count < pos_index

        @rule = rule
        @pos_index = pos_index
      end

      def is_item?
        true
      end

      # token is terminal
      def build_term(token)
        Term.new(self, token)
      end

      def ==(other)
        return false unless other.is_a?(RuleWithPos)

        (self.rule == other.rule) && (self.pos_index == other.pos_index)
      end
      alias :eql? :==

      def hash
        [@rule, @pos_index].hash
      end

      def as_array
        [@rule.id, @rule.left_token.name, @rule.right_tokens.map(&:name).insert(@pos_index, "*")]
      end

      def token_after_pos
        @rule.right_tokens[@pos_index]
      end

      # When [A -> α*Bβ, a], return β
      def tokens_after_pos
        @rule.right_tokens[(@pos_index + 1)..]
      end

      def right_shift_pos
        RuleWithPos.new(@rule, @pos_index + 1)
      end

      def to_s
        as_array.to_s
      end
      alias inspect to_s

      # Check if dot is end (e.g. "aB*")
      def dot_is_end?
        @rule.right_tokens.count == @pos_index
      end
    end

    # e.g. [S -> *E, $]
    class Term
      attr_reader :rule_with_pos, :token
      # token is terminal
      def initialize(rule_with_pos, token)
        @rule_with_pos = rule_with_pos
        @token = token
      end

      def rule
        @rule_with_pos.rule
      end

      def ==(other)
        return false unless other.is_a?(Term)

        (self.rule_with_pos == other.rule_with_pos) && (self.token == other.token)
      end
      alias :eql? :==

      def hash
        [@rule_with_pos, @token].hash
      end

      def as_array
        [@rule_with_pos.as_array, @token]
      end

      def to_s
        as_array.to_s
      end
      alias inspect to_s
    end

    class Station
      def initialize(n_token)
        @n_token = n_token
      end

      def token_after_pos
        @n_token
      end

      def is_item?
        false
      end

      def as_array
        ["*", @n_token.name]
      end
    end

    class Terminal
      attr_reader :id, :name

      def initialize(id, name)
        @id = id
        @name = name
      end

      def is_nonterminal?
        false
      end

      def is_terminal?
        true
      end

      def to_s
        "\"#{@name}\" (#{@id})"
      end

      def ==(other)
        return false unless other.is_a?(Terminal)

        self.name == other.name
      end
      alias :eql? :==

      def hash
        @name.hash
      end

      alias inspect to_s
    end

    class Nonterminal
      attr_reader :id, :name

      def initialize(id, name)
        @id = id
        @name = name
      end

      def is_nonterminal?
        true
      end

      def is_terminal?
        false
      end

      def to_s
        "\"#{@name}\" (#{@id})"
      end

      def ==(other)
        return false unless other.is_a?(Nonterminal)

        self.name == other.name
      end
      alias :eql? :==

      def hash
        @name.hash
      end

      alias inspect to_s
    end
  end
end
