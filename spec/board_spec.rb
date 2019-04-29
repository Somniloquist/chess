require "board.rb"

describe Board do
  describe "#initialize" do
    it "creates an 8x8 board" do
      board = Board.new(8,8).grid
      expect(board.join.size).to eql(8*8)
    end
  end

end