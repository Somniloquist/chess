require "player.rb"

describe Player do
  describe "#initialize" do
    it "creates a player named 'player1' with color 'white'" do
      p1 = Player.new("player1", :white)
      expect(p1.name).to eql("player1")
      expect(p1.color).to eql(:white)
    end
    it "creates a player named 'player2' with color 'black'" do
      p1 = Player.new("player2", :black)
      expect(p1.name).to eql("player2")
      expect(p1.color).to eql(:black)
    end
  end
end