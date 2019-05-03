require "piece.rb"

describe Piece do
  describe "#initialize" do
    it "creates a black knight" do
      knight = Piece.new(:knight, :black)
      expect(knight.type).to eql(:knight)
      expect(knight.color).to eql(:black)
      expect(knight.moves).to eql([[-1,2],[-2,1],[2,1],[1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]])
    end

    it "creates a white rook" do
      knight = Piece.new(:rook, :white)
      expect(knight.type).to eql(:rook)
      expect(knight.color).to eql(:white)
      expect(knight.moves).to eql([ [1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],
            [-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0],
            [0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],
            [0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7] ])
    end
  end

end