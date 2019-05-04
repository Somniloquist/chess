require "board.rb"
require "piece.rb"
include ChessPieceSymbols

describe Board do
  describe "#initialize" do
    it "creates an 8x8 board" do
      size = 0
      board = Board.new.grid
      board.each {|row| row.each { size += 1 } }
      expect(size).to eql(8*8)
    end

    it "has proper placement of chess pieces" do
      board = Board.new
      columns = "abcdefgh".split("")
      
      columns.each { |column| expect(board["#{column}2".to_sym].symbol).to eql(SYMBOLS[:pawnwhite]) }
      expect(board[:a1].symbol).to eql(SYMBOLS[:rookwhite])
      expect(board[:b1].symbol).to eql(SYMBOLS[:knightwhite])
      expect(board[:c1].symbol).to eql(SYMBOLS[:bishopwhite])
      expect(board[:d1].symbol).to eql(SYMBOLS[:queenwhite])
      expect(board[:e1].symbol).to eql(SYMBOLS[:kingwhite])
      expect(board[:f1].symbol).to eql(SYMBOLS[:bishopwhite])
      expect(board[:g1].symbol).to eql(SYMBOLS[:knightwhite])
      expect(board[:h1].symbol).to eql(SYMBOLS[:rookwhite])

      columns.each { |column| expect(board["#{column}7".to_sym].symbol).to eql(SYMBOLS[:pawnblack]) }
      expect(board[:a8].symbol).to eql(SYMBOLS[:rookblack])
      expect(board[:b8].symbol).to eql(SYMBOLS[:knightblack])
      expect(board[:c8].symbol).to eql(SYMBOLS[:bishopblack])
      expect(board[:d8].symbol).to eql(SYMBOLS[:queenblack])
      expect(board[:e8].symbol).to eql(SYMBOLS[:kingblack])
      expect(board[:f8].symbol).to eql(SYMBOLS[:bishopblack])
      expect(board[:g8].symbol).to eql(SYMBOLS[:knightblack])
      expect(board[:h8].symbol).to eql(SYMBOLS[:rookblack])
    end
 end

  describe "#[]" do
    it "gets/sets a value at a location using chess notation" do
      board = Board.new
      expect(board[:e5]).to eql("")
      board[:e5] = "test"
      expect(board[:e5]).to eql("test")
    end
  end

  describe "#moves" do
    it "returns a list of possible moves" do
      knight = Piece.new(:knight, :white)
      expect(knight.moves).to eql([[-1,2],[-2,1],[2,1],[1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]])
    end
  end
  
end