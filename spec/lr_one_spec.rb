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
end
