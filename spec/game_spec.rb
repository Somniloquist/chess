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
      expect(game.make_play(:a2, :a3)).to eql(:a3)
    end

    it "returns false / does not allow move if path if blocked (pawn)" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      pawn_black = Pawn.new(:black)
      game.board[:a3] = pawn_black
      
      expect(game.make_play(:a2, :a3)).to eql(false)
      expect(board[:a3]).to eql(pawn_black)
    end

    it "returns false / does not allow move if path if blocked (queen)" do
      board = Board.new
      board.clear
      game = Game.new(board, Player.new("p1", :white), Player.new("p2", :black))
      queen_white = board[:d4] = Piece.new(:queen, :white)
      board[:d6] = Piece.new(:knight, :black)
      board[:d2] = Piece.new(:knight, :black)
      board[:b4] = Piece.new(:knight, :black)
      board[:f4] = Piece.new(:knight, :black)
      board[:b6] = Piece.new(:knight, :black)
      board[:f6] = Piece.new(:knight, :black)
      board[:f2] = Piece.new(:knight, :black)
      board[:b2] = Piece.new(:knight, :black)

      expect(game.make_play(:d4, :d8)).to eql(false)
      expect(game.make_play(:d4, :d1)).to eql(false)
      expect(game.make_play(:d4, :a4)).to eql(false)
      expect(game.make_play(:d4, :h4)).to eql(false)

      expect(game.make_play(:d4, :h8)).to eql(false)
      expect(game.make_play(:d4, :a7)).to eql(false)
      expect(game.make_play(:d4, :a1)).to eql(false)
      expect(game.make_play(:d4, :g1)).to eql(false)

      expect(board[:d4]).to eql(queen_white)
    end

    it "allows knight to 'jump' over other pieces" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      knight = board[:b1]
      expect(board[:b1]).to eql(knight) 
      expect(board[:c3]).to eql("")
      
      game.make_play(:b1, :c3)
      
      expect(board[:b1]).to eql("") 
      expect(board[:c3]).to eql(knight)
    end

    # it "returns false /does not allow move if path if blocked" do
    #   board = Board.new
    #   p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
    #   game = Game.new(board, p1, p2)
    # end

  end

  # # TEMPORARY TESTS, TEST RESULTS FOR PRIVATE FUNCTIONS
  # describe "#get_move_path" do
  #   it "returns path for horizontal movement" do
  #     board = Board.new
  #     board.clear
  #     p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
  #     game = Game.new(board, p1, p2) 
      
  #     # expect(game.get_move_path(:b1, :h1)).to eql([[0,2],[0,3], [0,4], [0,5], [0,6], [0,7]])
  #     expect(game.get_move_path(:b1, :h1)).to eql([:c1, :d1, :e1, :f1, :g1, :h1])
  #   end

  #   it "returns path for horizontal movement in opposite direction" do
  #     board = Board.new
  #     board.clear
  #     p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
  #     game = Game.new(board, p1, p2) 

  #     # expect(game.get_move_path(:h3, :b3)).to eql([[2,6], [2,5], [2,4], [2,3], [2,2], [2,1]])
  #     expect(game.get_move_path(:h3, :b3)).to eql([:g3, :f3, :e3, :d3, :c3, :b3])
  #   end

  #   it "returns path for verticle movement" do
  #     board = Board.new
  #     board.clear
  #     p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
  #     game = Game.new(board, p1, p2) 
      
  #     # expect(game.get_move_path(:b2, :b6)).to eql([[2,1],[3,1],[4,1],[5,1]])
  #     expect(game.get_move_path(:b2, :b6)).to eql([:b3, :b4, :b5, :b6])
  #   end

  #   it "returns path for verticle movement in opposite direction" do
  #     board = Board.new
  #     board.clear
  #     p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
  #     game = Game.new(board, p1, p2) 
      
  #     # expect(game.get_move_path(:e6, :e2)).to eql([[4,4], [3,4], [2,4], [1,4]])
  #     expect(game.get_move_path(:e6, :e2)).to eql([:e5, :e4, :e3, :e2])
  #   end

  #   it "returns path for diagonal movement" do
  #     board = Board.new
  #     board.clear
  #     p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
  #     game = Game.new(board, p1, p2) 
      
  #     expect(game.get_move_path(:b2, :e5)).to eql([:c3, :d4, :e5])
  #     expect(game.get_move_path(:e5, :b2)).to eql([:d4, :c3, :b2])
  #     expect(game.get_move_path(:f2, :c5)).to eql([:e3, :d4, :c5])
  #     expect(game.get_move_path(:c5, :f2)).to eql([:d4, :e3, :f2])
  #   end
  # end

end
