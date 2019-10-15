require "set"

RSpec.describe Parzer::Lr_One do
  let(:context) do
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

  describe "#first" do
    it do
      tokens = context.tokens
      n_tokens = context.n_tokens

      expect(context.first(n_tokens[:S])).to eq(Set.new([tokens[:"("], tokens[:"n"]]))
      expect(context.first(n_tokens[:E])).to eq(Set.new([tokens[:"("], tokens[:"n"]]))
      expect(context.first(n_tokens[:T])).to eq(Set.new([tokens[:"("], tokens[:"n"]]))
    end
  end

  describe "#follow" do
    it do
      tokens = context.tokens
      n_tokens = context.n_tokens

      expect(context.follow(n_tokens[:S])).to eq(Set.new([tokens[:"$"]]))
      expect(context.follow(n_tokens[:E])).to eq(Set.new([tokens[:"-"], tokens[:")"], tokens[:"$"]]))
      expect(context.follow(n_tokens[:T])).to eq(Set.new([tokens[:"-"], tokens[:")"], tokens[:"$"]]))
    end
  end
end
