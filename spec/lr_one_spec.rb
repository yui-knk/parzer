require "set"

RSpec.describe Parzer::Lr_One do
  let(:context_1) do
    context = Parzer::Lr_One.define_syntax do |c|
      c.token("-")
      c.token("(")
      c.token(")")
      c.token("n")

      c.rule("S", "E", "$")
      c.rule("E", "E", "-", "T")
      c.rule("E", "T")
      c.rule("T", "n")
      c.rule("T", "(", "E", ")")
    end
  end

  let(:context_2) do
    context = Parzer::Lr_One.define_syntax do |c|
      # https://ja.wikipedia.org/wiki/%E6%AD%A3%E8%A6%8FLR%E6%B3%95#First%E9%9B%86%E5%90%88%E3%81%A8Follow%E9%9B%86%E5%90%88
      c.token("n")
      c.token("+")
      c.token("(")
      c.token(")")

      c.rule("S", "E")
      c.rule("E", "T")
      c.rule("E", "(", "E", ")")
      c.rule("T", "n")
      c.rule("T", "+", "T")
      c.rule("T", "T", "+", "n")
    end
  end

  let(:context_3) do
    context = Parzer::Lr_One.define_syntax do |c|
      # 478191229X P.282
      c.token("c")
      c.token("d")

      c.rule("S'", "S")
      c.rule("S", "C", "C")
      c.rule("C", "c", "C")
      c.rule("C", "d")
    end
  end

  describe "#first" do
    it do
      tokens = context_2.tokens
      n_tokens = context_2.n_tokens

      expect(context_2.first(n_tokens[:S])).to eq(Set.new([tokens[:"n"], tokens[:"+"], tokens[:"("]]))
      expect(context_2.first(n_tokens[:E])).to eq(Set.new([tokens[:"n"], tokens[:"+"], tokens[:"("]]))
      expect(context_2.first(n_tokens[:T])).to eq(Set.new([tokens[:"n"], tokens[:"+"]]))
    end
  end

  describe "#follow" do
    it do
      tokens = context_2.tokens
      n_tokens = context_2.n_tokens

      expect(context_2.follow(n_tokens[:S])).to eq(Set.new([tokens[:"$"]]))
      expect(context_2.follow(n_tokens[:E])).to eq(Set.new([tokens[:")"], tokens[:"$"]]))
      expect(context_2.follow(n_tokens[:T])).to eq(Set.new([tokens[:"+"], tokens[:")"], tokens[:"$"]]))
    end
  end

  describe "context_3" do
    describe "#build_state" do
      it do
        tokens = context_3.tokens
        r = context_3.rules.first

        context_3.build_state(r.build_term(0, tokens[:"$"]))
      end
    end

    describe "#construct_parse_table" do
      it do
        tokens = context_3.tokens
        n_tokens = context_3.n_tokens
        rules = context_3.rules
        # S' -> S
        rule_1 = rules[0]
        # S -> CC
        rule_2 = rules[1]
        # C -> cC
        rule_3 = rules[2]
        # C -> d
        rule_4 = rules[3]

        i0 = Set.new([
          rule_1.build_term(0, tokens[:"$"]),
          rule_2.build_term(0, tokens[:"$"]),
          rule_3.build_term(0, tokens[:"c"]),
          rule_3.build_term(0, tokens[:"d"]),
          rule_4.build_term(0, tokens[:"c"]),
          rule_4.build_term(0, tokens[:"d"]),
        ])

        i1 = Set.new([
          rule_1.build_term(1, tokens[:"$"]),
        ])

        i2 = Set.new([
          rule_2.build_term(1, tokens[:"$"]),
          rule_3.build_term(0, tokens[:"$"]),
          rule_4.build_term(0, tokens[:"$"]),
        ])

        i3 = Set.new([
          rule_3.build_term(1, tokens[:"c"]),
          rule_3.build_term(1, tokens[:"d"]),
          rule_3.build_term(0, tokens[:"c"]),
          rule_3.build_term(0, tokens[:"d"]),
          rule_4.build_term(0, tokens[:"c"]),
          rule_4.build_term(0, tokens[:"d"]),
        ])

        i4 = Set.new([
          rule_4.build_term(1, tokens[:"c"]),
          rule_4.build_term(1, tokens[:"d"]),
        ])

        i5 = Set.new([
          rule_2.build_term(2, tokens[:"$"]),
        ])

        i6 = Set.new([
          rule_3.build_term(1, tokens[:"$"]),
          rule_3.build_term(0, tokens[:"$"]),
          rule_4.build_term(0, tokens[:"$"]),
        ])

        i7 = Set.new([
          rule_4.build_term(1, tokens[:"$"]),
        ])

        i8 = Set.new([
          rule_3.build_term(2, tokens[:"c"]),
          rule_3.build_term(2, tokens[:"d"]),
        ])

        i9 = Set.new([
          rule_3.build_term(2, tokens[:"$"]),
        ])

        s, t = context_3.construct_parse_table

        get_next_state_id = -> state, token do
          ac = t.detect {|p| p[0] == state && p[1] == token }
          ac[2]
        end

        expect(s.count).to eq 10
        expect(t.count).to eq 13

        ei0_id = 1
        ei0 = s[ei0_id]
        expect(ei0).to eq(i0)

        ei1_id = get_next_state_id.call(ei0_id, n_tokens[:"S"])
        ei1 = s[ei1_id]
        expect(ei1).to eq(i1)

        ei2_id = get_next_state_id.call(ei0_id, n_tokens[:"C"])
        ei2 = s[ei2_id]
        expect(ei2).to eq(i2)

        ei3_id = get_next_state_id.call(ei0_id, tokens[:"c"])
        ei3 = s[ei3_id]
        expect(ei3).to eq(i3)

        ei3_id = get_next_state_id.call(ei3_id, tokens[:"c"])
        ei3 = s[ei3_id]
        expect(ei3).to eq(i3)

        ei4_id = get_next_state_id.call(ei0_id, tokens[:"d"])
        ei4 = s[ei4_id]
        expect(ei4).to eq(i4)

        ei4_id = get_next_state_id.call(ei3_id, tokens[:"d"])
        ei4 = s[ei4_id]
        expect(ei4).to eq(i4)

        ei5_id = get_next_state_id.call(ei2_id, n_tokens[:"C"])
        ei5 = s[ei5_id]
        expect(ei5).to eq(i5)

        ei6_id = get_next_state_id.call(ei2_id, tokens[:"c"])
        ei6 = s[ei6_id]
        expect(ei6).to eq(i6)

        ei6_id = get_next_state_id.call(ei6_id, tokens[:"c"])
        ei6 = s[ei6_id]
        expect(ei6).to eq(i6)

        ei7_id = get_next_state_id.call(ei2_id, tokens[:"d"])
        ei7 = s[ei7_id]
        expect(ei7).to eq(i7)

        ei7_id = get_next_state_id.call(ei6_id, tokens[:"d"])
        ei7 = s[ei7_id]
        expect(ei7).to eq(i7)

        ei8_id = get_next_state_id.call(ei3_id, n_tokens[:"C"])
        ei8 = s[ei8_id]
        expect(ei8).to eq(i8)

        ei9_id = get_next_state_id.call(ei6_id, n_tokens[:"C"])
        ei9 = s[ei9_id]
        expect(ei9).to eq(i9)
      end
    end
  end
end
