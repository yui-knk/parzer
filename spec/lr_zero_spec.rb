RSpec.describe Parzer::Lr_Zero do
  let(:context) do
    context = Parzer::Lr_Zero.define_syntax do |c|
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

  it "#stations" do
    expect(context.stations.map(&:as_array)).to eq([["*", :S], ["*", :E], ["*", :T]])
  end

  it "#items" do
    expect(context.items.map(&:as_array)).to eq([
      [1, :S, ["*", :E, :"$"]],
      [1, :S, [:E, "*", :"$"]],
      [1, :S, [:E, :"$", "*"]],
      [2, :E, ["*", :E, :"-", :T]],
      [2, :E, [:E, "*", :"-", :T]],
      [2, :E, [:E, :"-", "*", :T]],
      [2, :E, [:E, :"-", :T, "*"]],
      [3, :E, ["*", :T]],
      [3, :E, [:T, "*"]],
      [4, :T, ["*", :n]],
      [4, :T, [:n, "*"]],
      [5, :T, ["*", :"(", :E, :")"]],
      [5, :T, [:"(", "*", :E, :")"]],
      [5, :T, [:"(", :E, "*", :")"]],
      [5, :T, [:"(", :E, :")", "*"]],
    ])
  end

  it "#construct_parse_table" do
    s, t = context.construct_parse_table

    expect(s.count).to eq 10
    expect(t.count).to eq 15
  end

  it "#action_goto_tables" do
    action, goto = context.action_goto_tables
  end

  it "#parse" do
    lexer = Class.new do
      def initialize
        @tokens = [:n, :-, :n, :-, :n, :"$"]
      end

      def next_token
        @tokens.shift
      end
    end.new

    parser = context.build_parser(lexer)
    parser.parse
  end
end
