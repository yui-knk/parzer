require "set"
require "parzer/lr_one"

module Parzer
  module Lalr_One
    def self.define_syntax(&block)
      lr_one_context = Lr_One.define_syntax(&block)
      context = Context.new(lr_one_context)
      context.syntax_definition_completed

      return context
    end

    class Context
      def initialize(lr_one_context)
        @lr_one_context = lr_one_context
        @syntax_definition_completed = false
        @debug = false
      end

      def syntax_definition_completed
        return if @syntax_definition_completed

        @lr_one_context.syntax_definition_completed
        @syntax_definition_completed = true
      end

      def action_goto_tables(debug = false)
        with_debug(debug) do
          tokens = @lr_one_context.tokens
          n_tokens = @lr_one_context.n_tokens
          lr_one_action_table, lr_one_goto_table, lr_one_s, lr_one_t = @lr_one_context.action_goto_tables

          cores_hash = {}
          lr_one_s.each do |k, states|
            cores = states.map do |state|
              state.rule_with_pos
            end
            cores_hash[k] = Set.new(cores)
          end

          merge_candidates = {}
          cores_hash.each do |k, cores|
            merge_candidates[cores] ||= []
            merge_candidates[cores] << k
          end

          s = {}
          # lr_one_state_id_to_lalr_one_lr_one
          lr_one_to_lalr_one = {}
          id = 1
          merge_candidates.values.each do |ids|
            log("#{ids} will be merged.")

            merged = ids.each_with_object(Set.new) do |id, set|
              set.merge(lr_one_s[id])
            end

            ids.each do |lr_one_state_id|
              lr_one_to_lalr_one[lr_one_state_id] = id
            end

            s[id] = merged
            id += 1
          end

          action_table = []
          goto_table = []

          s.count.times do |i|
            action_table[i + 1] = []
            goto_table[i + 1] = []
          end

          lr_one_s.keys.each do |state_id|
            tokens.each do |_, token|
              # action
              ac = lr_one_action_table[state_id][token.id]
              lalr_state_id = lr_one_to_lalr_one[state_id]

              case ac
              when nil
                # noop
              when :acc
                action_table[lalr_state_id][token.id] = :acc
              when /^shift_(\d+)$/
                action_table[lalr_state_id][token.id] = :"shift_#{lr_one_to_lalr_one[$1.to_i]}"
              when /^reduce_(\d+)$/
                action_table[lalr_state_id][token.id] = :"reduce_#{lr_one_to_lalr_one[$1.to_i]}"
              else
                raise "Unknown action: #{ac}."
              end

              # goto
              g = lr_one_goto_table[state_id][token.id]

              if g.nil?
                # noop
              else
                goto_table[lalr_state_id][token.id] = lr_one_to_lalr_one[g]
              end
            end
          end

          return action_table, goto_table, s
        end
      end

      private

      def goto(target_terms, token)
        @lr_one_context.send(:goto, target_terms, token)
      end

      def ensure_syntax_definition_completed!
        raise "You should complete syntax definition." if !@syntax_definition_completed
      end

      def with_debug(debug, &block)
        debug_before = @debug
        block.call
      ensure
        @debug = debug_before
      end

      def log(msg)
        p(msg) if @debug
      end
    end
  end
end
