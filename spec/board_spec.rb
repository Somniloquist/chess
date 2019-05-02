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
      columns = "ABCDEFGH".split("")
      
      columns.each { |column| expect(board.cell("#{column}2".to_sym).symbol).to eql(SYMBOLS[:pawnwhite]) }
      expect(board.cell(:A1).symbol).to eql(SYMBOLS[:rookwhite])
      expect(board.cell(:B1).symbol).to eql(SYMBOLS[:knightwhite])
      expect(board.cell(:C1).symbol).to eql(SYMBOLS[:bishopwhite])
      expect(board.cell(:D1).symbol).to eql(SYMBOLS[:queenwhite])
      expect(board.cell(:E1).symbol).to eql(SYMBOLS[:kingwhite])
      expect(board.cell(:F1).symbol).to eql(SYMBOLS[:bishopwhite])
      expect(board.cell(:G1).symbol).to eql(SYMBOLS[:knightwhite])
      expect(board.cell(:H1).symbol).to eql(SYMBOLS[:rookwhite])

      columns.each { |column| expect(board.cell("#{column}7".to_sym).symbol).to eql(SYMBOLS[:pawnblack]) }
      expect(board.cell(:A8).symbol).to eql(SYMBOLS[:rookblack])
      expect(board.cell(:B8).symbol).to eql(SYMBOLS[:knightblack])
      expect(board.cell(:C8).symbol).to eql(SYMBOLS[:bishopblack])
      expect(board.cell(:D8).symbol).to eql(SYMBOLS[:queenblack])
      expect(board.cell(:E8).symbol).to eql(SYMBOLS[:kingblack])
      expect(board.cell(:F8).symbol).to eql(SYMBOLS[:bishopblack])
      expect(board.cell(:G8).symbol).to eql(SYMBOLS[:knightblack])
      expect(board.cell(:H8).symbol).to eql(SYMBOLS[:rookblack])
    end
 end

end