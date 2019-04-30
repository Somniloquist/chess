require "board.rb"

describe Board do
  describe "#initialize" do
    it "creates an 8x8 board" do
      size = 0
      board = Board.new.grid
      board.each {|row| row.each { size += 1 } }
      expect(size).to eql(8*8)
    end
  end

end