require "set"

RSpec.describe Parzer::Lalr_One do
  let(:context_3) do
    context = Parzer::Lalr_One.define_syntax do |c|
      # 478191229X P.282
      c.token("c")
      c.token("d")

      c.rule("S'", "S")
      c.rule("S", "C", "C")
      c.rule("C", "c", "C")
      c.rule("C", "d")
    end
  end

  describe "context_3" do
    describe "#action_goto_tables" do
      it do
        action, goto, s = context_3.action_goto_tables
      end
    end
  end
end
