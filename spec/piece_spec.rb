require "piece.rb"

describe Piece do
  describe "#initialize" do
    it "creates a black knight" do
      knight = Piece.new(:knight, :black)
      expect(knight.type).to eql(:knight)
      expect(knight.color).to eql(:black)
      expect(knight.moves).to eql([[-1,2],[-2,1],[2,1],[1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]])
    end
  end

end