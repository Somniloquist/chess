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

  describe "#make_play" do
    it "returns false if a chess piece is not chosen" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      expect(game.make_play(:c3, :c4)).to eql(false)
    end

    it "returns false if a starting or ending cell doesn't exist" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      expect(game.make_play(:b8, :d9)).to eql(false)
      expect(game.make_play(:b9, :d8)).to eql(false)
    end

    it "returns false if a piece and player color don't match" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p2
      expect(game.make_play(:a2, :a3)).to eql(false)
    end

    it "returns true if a piece and player color match" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p1
      expect(game.make_play(:a2, :a3)).to eql(:a3)
    end

   it "returns false if movement path is blocked by another piece" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p1
      game.board[:a3] = Pawn.new(:black)
      
      expect(game.make_play(:a2, :a3)).to eql(false)
      expect(board[:a3]).to eql
    end

    it "allows knight to 'jump' over other pieces" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p1

      knight = board[:b1]
      expect(board[:b1]).to eql(knight) 
      expect(board[:c3]).to eql("")
      
      game.make_play(:b1, :c3)
      
      expect(board[:b1]).to eql("") 
      expect(board[:c3]).to eql(knight)
    end

    xit "moves knight from b1 to c3" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      knight = Piece.new(:knight, :white)

      board[:b1] = knight
      expect(board[:b1]).to eql(knight)
      expect(board[:c3]).to eql("")

      game.make_play(:b1, :c3)

      expect(board[:b1]).to eql("")
      expect(board[:c3]).to eql(knight)
    end
  end

  describe "#get_move_path" do
    it "returns path for horizontal movement" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      
      board[:b1] = Piece.new(:rook, :white)
      board[:g1] = Piece.new(:knight, :white)
      
      expect(game.get_move_path(:b1, :h1)).to eql([[0,2],[0,3], [0,4], [0,5], [0,6], [0,7]])
      
    end

    it "returns path for horizontal movement in opposite direction" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      
      board[:b1] = Piece.new(:rook, :white)
      board[:g1] = Piece.new(:knight, :white)
      
      expect(game.get_move_path(:h3, :b3)).to eql([[2,2],[2,3], [2,4], [2,5], [2,6], [2,7]].reverse)
      
    end
  end

end