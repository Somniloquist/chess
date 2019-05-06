require "game.rb"

describe Game do
  describe "#get_possible_moves" do 
    it "returns a list of valid moves for a knight" do
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      board = Board.new
      board.clear
      game = Game.new(board, p1, p2)
      knight = Piece.new(:knight, :white)

      board[:b2] = knight
      moves = game.get_possible_moves(knight, :b2)
      expect(moves.sort).to eql([:a4, :c4, :d1, :d3])
    end

    it "returns a list of valid moves for a rook" do
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      board = Board.new
      board.clear
      game = Game.new(board, p1, p2)
      rook = Piece.new(:rook, :white)

      board[:b2] = rook 
      moves = game.get_possible_moves(rook, :b2)
      expect(moves.sort).to eql([:a2, :b1, :b3, :b4, :b5, :b6, :b7, :b8, :c2, :d2, :e2, :f2, :g2, :h2])
    end
  end

  describe "#move_piece" do
    it "moves knight from b1 to c3" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      knight = Piece.new(:knight, :white)

      board[:b1] = knight
      expect(board[:b1]).to eql(knight)
      expect(board[:c3]).to eql("")

      game.move_piece(:b1, :c3)

      expect(board[:b1]).to eql("")
      expect(board[:c3]).to eql(knight)
    end

  end

end