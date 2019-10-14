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
    expect(context.stations).to eq([["*", :S], ["*", :E], ["*", :T]])
  end

  it "#items" do
    expect(context.items).to eq([
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
end
