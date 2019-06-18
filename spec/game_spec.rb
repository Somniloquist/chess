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

    it "returns a list of valid moves for a pawn(white)" do
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      board = Board.new
      game = Game.new(board, p1, p2)

      pawn_white = board[:a2]
      moves = game.get_possible_moves(pawn_white, :a2)
      expect(moves.sort).to eql([:a3, :a4])

      game.make_play(:a2, :a4)

      moves = game.get_possible_moves(pawn_white, :a4)
      expect(moves.sort).to eql([:a5])
    end

    it "returns a list of valid moves for a pawn(black)" do
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      board = Board.new
      game = Game.new(board, p1, p2)
      game.current_player = p2

      pawn_black = board[:a7]
      moves = game.get_possible_moves(pawn_black, :a7)
      expect(moves.sort).to eql([:a5, :a6])

      game.make_play(:a7, :a5)

      moves = game.get_possible_moves(pawn_black, :a5)
      expect(moves.sort).to eql([:a4])
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
      king_white = Piece.new(:king, :white)
      game.board[:a3] = king_white
      
      expect(game.make_play(:a2, :a3)).to eql(false)
      expect(board[:a3]).to eql(king_white)
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

    it "moves pawn from a7 to a6" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p2
      
      pawn_black = Pawn.new(:black)
      board[:a7] = pawn_black

      game.make_play(:a7, :a8) #illegal move
      expect(board[:a7]).to eql(pawn_black)
      expect(board[:a8]).to eql("")

      game.make_play(:a7, :a3) #illegal move
      expect(board[:a7]).to eql(pawn_black)
      expect(board[:a3]).to eql("")

      game.make_play(:a7, :a6) # legal move
      expect(board[:a7]).to eql("")
      expect(board[:a6]).to eql(pawn_black)
    end

    it "moves rook from c5 to f5" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p2

      rook_black = Piece.new(:rook, :black)
      board[:c5] = rook_black
      board[:g5] = Piece.new(:rook, :white)

      game.make_play(:c5, :h5) #illegal move
      expect(board[:c5]).to eql(rook_black)
      expect(board[:h5]).to eql("")
      game.make_play(:c5, :d4) #illegal move
      expect(board[:c5]).to eql(rook_black)
      expect(board[:d4]).to eql("")
      game.make_play(:c5, :f5) #legal move
      expect(board[:c5]).to eql("")
      expect(board[:f5]).to eql(rook_black)
    end

    it "does not allow move to space occupied by friendly piece" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      rook_white = Piece.new(:rook, :white)
      pawn_white =  board[:a2]
      board[:a3] = rook_white

      game.make_play(:a3, :a2)
      expect(board[:a2]).to eql(pawn_white)
      expect(board[:a3]).to eql(rook_white)
    end

    it "allows double move if pawn has not yet moved" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      # white pawn
      pawn_white = board[:a2]
      game.make_play(:a2, :a4)
      expect(board[:a4]).to eql(pawn_white)
      game.make_play(:a4, :a6)
      expect(board[:a4]).to eql(pawn_white)
      expect(board[:a6]).to eql("")

      # black pawn
      game.current_player = p2
      pawn_black = board[:a7]
      game.make_play(:a7, :a5)
      expect(board[:a5]).to eql(pawn_black)
      game.make_play(:a5, :a3)
      expect(board[:a5]).to eql(pawn_black)
      expect(board[:a3]).to eql("")
    end

    it "white rook captures black pawn" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      rook_white = Piece.new(:rook, :white)
      pawn_black = board[:a7]
      board[:a3] = rook_white

      expect(board[:a7]).to eql(pawn_black)
      game.make_play(:a3, :a7)
      expect(board[:a7]).to eql(rook_white)
    end

    it "pawn cannot capture piece directly in front" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      pawn_white = board[:a2]
      pawn_black = Pawn.new(:black)
      board[:a3] = pawn_black

      expect(board[:a2]).to eql(pawn_white)
      expect(board[:a3]).to eql(pawn_black)
      game.make_play(:a2, :a3)
      expect(board[:a2]).to eql(pawn_white)
      expect(board[:a3]).to eql(pawn_black)
    end

    it "pawn captures diagonally (white pawn)" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      pawn_white1 = Pawn.new(:white)
      pawn_white2 = Pawn.new(:white)
      pawn_black1 = board[:a7]
      pawn_black2 = board[:d7]
      board[:b6] = pawn_white1
      board[:c6] = pawn_white2

      expect(board[:a7]).to eql(pawn_black1)
      game.make_play(:b6, :a7)
      expect(board[:a7]).to eql(pawn_white1)
      expect(board[:b6]).to eql("")

      expect(board[:d7]).to eql(pawn_black2)
      game.make_play(:c6, :d7)
      expect(board[:d7]).to eql(pawn_white2)
      expect(board[:c6]).to eql("")
    end

    it "pawn captures diagonally (black pawn)" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)
      game.current_player = p2

      pawn_black1 = Pawn.new(:black)
      pawn_black2 = Pawn.new(:black)
      pawn_white1 = board[:a2]
      pawn_white2 = board[:d2]
      board[:b3] = pawn_black1
      board[:c3] = pawn_black2

      expect(board[:a2]).to eql(pawn_white1)
      game.make_play(:b3, :a2)
      expect(board[:a2]).to eql(pawn_black1)
      expect(board[:b3]).to eql("")

      expect(board[:d2]).to eql(pawn_white2)
      game.make_play(:c3, :d2)
      expect(board[:d2]).to eql(pawn_black2)
      expect(board[:c3]).to eql("")
    end

    it "non-knights cannot capture 'over' other pieces" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2)

      rook_white = Piece.new(:rook, :white)
      rook_black = board[:a8]
      board[:a3] = rook_white

      expect(board[:a3]).to eql(rook_white)
      expect(board[:a8]).to eql(rook_black)
      game.make_play(:a3, :a8)
      expect(board[:a3]).to eql(rook_white)
      expect(board[:a8]).to eql(rook_black)
    end

  end

  describe "#get_move_path" do
    it "returns path for horizontal movement" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      
      expect(game.get_move_path(:b1, :h1)).to eql([:c1, :d1, :e1, :f1, :g1, :h1])
    end

    it "returns path for horizontal movement in opposite direction" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      expect(game.get_move_path(:h3, :b3)).to eql([:g3, :f3, :e3, :d3, :c3, :b3])
    end

    it "returns path for verticle movement" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      
      expect(game.get_move_path(:b2, :b6)).to eql([:b3, :b4, :b5, :b6])
    end

    it "returns path for verticle movement in opposite direction" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      
      expect(game.get_move_path(:e6, :e2)).to eql([:e5, :e4, :e3, :e2])
    end

    it "returns path for diagonal movement" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      
      expect(game.get_move_path(:b2, :e5)).to eql([:c3, :d4, :e5])
      expect(game.get_move_path(:d1, :h5)).to eql([:e2, :f3, :g4, :h5])
      expect(game.get_move_path(:e5, :b2)).to eql([:d4, :c3, :b2])
      expect(game.get_move_path(:f2, :c5)).to eql([:e3, :d4, :c5])
      expect(game.get_move_path(:c5, :f2)).to eql([:d4, :e3, :f2])
    end
  end

  describe "#player_in_check?" do
    it "returns true when king is in another piece's path" do
        board = Board.new
        board.clear
        p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
        game = Game.new(board, p1, p2) 

        board[:a1] = Piece.new(:king, :white)
        board[:b3] = Piece.new(:knight, :black)

        king_location = game.get_king_location(:white)
        enemy_paths = game.get_all_possible_paths(:black)

        expect(game.player_in_check?).to eql(true)
    end
    
    it "returns false when enemy's capture path is blocked" do
        board = Board.new
        p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
        game = Game.new(board, p1, p2) 

        board[:e1] = ""
        board[:e5] = Piece.new(:king, :white)

        king_location = game.get_king_location(:white)
        enemy_paths = game.get_all_possible_paths(:black)

        expect(game.player_in_check?).to eql(false)
    end
  end

  describe "#get_king_location" do
    it "returns location of king of specified color" do
        board = Board.new
        p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
        game = Game.new(board, p1, p2) 

        expect(game.get_king_location(:white)).to eql(:e1)
        expect(game.get_king_location(:black)).to eql(:e8)

        board.clear
        board[:f3] = Piece.new(:king, :white)
        expect(game.get_king_location(:white)).to eql(:f3)
    end
  end

  describe "#trim_king_moves!" do
    it "returns an array with moves that would put the king in check removed" do
      board = Board.new
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:e1] = ""
      board[:e5] = Piece.new(:king, :white)
      board[:f3] = Piece.new(:rook, :black)

      enemy_moves = game.get_all_possible_paths(:black)
      king_moves = game.get_possible_moves(board[:e5], :e5)
      king_moves = game.trim_king_moves(king_moves, enemy_moves)
      expect(king_moves).to eql([:e4, :d4, :d5])
    end

    it "returns an empty array when there are no safe moves" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:e1] = ""
      board[:e5] = Piece.new(:king, :white)
      board[:d6] = Piece.new(:rook, :black)
      board[:d4] = Piece.new(:rook, :black)
      board[:f4] = Piece.new(:rook, :black)

      enemy_moves = game.get_all_possible_paths(:black)
      king_moves = game.get_possible_moves(board[:e5], :e5)
      king_moves = game.trim_king_moves(king_moves, enemy_moves)
      expect(king_moves).to eql([])
    end

    it "returns an empty array when there are no safe moves" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:e1] = Piece.new(:king, :white)
      board[:a1] = Piece.new(:rook, :black)
      board[:a2] = Piece.new(:rook, :black)

      enemy_moves = game.get_all_possible_paths(:black)
      king_moves = game.get_possible_moves(board[:e1], :e1)
      king_moves = game.trim_king_moves(king_moves, enemy_moves)
      expect(king_moves).to eql([])
    end
  end

  describe "#checkmate" do
   it "returns true when king is in check and has no legal moves available" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:e1] = ""
      board[:e5] = Piece.new(:king, :white)
      board[:d6] = Piece.new(:rook, :black)
      board[:f4] = Piece.new(:rook, :black)
      board[:d4] = Piece.new(:queen, :black)

      expect(game.checkmate?).to eql(true)
   end

    it "returns false when king is in check but still has legal moves" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:e1] = ""
      board[:e5] = Piece.new(:king, :white)
      board[:d6] = Piece.new(:rook, :black)
      board[:f4] = Piece.new(:rook, :black)

      expect(game.checkmate?).to eql(false)
    end

    it "returns false when another piece can block the check" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:e1] = ""
      board[:e1] = Piece.new(:king, :white)
      board[:f3] = Piece.new(:bishop, :white)
      board[:a1] = Piece.new(:rook, :black)
      board[:a2] = Piece.new(:rook, :black)

      expect(game.checkmate?).to eql(false)
    end

    it "returns false when another piece isn't enough to block the check" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      board[:e1] = Piece.new(:king, :white)
      board[:f3] = Piece.new(:bishop, :white)
      board[:a1] = Piece.new(:rook, :black)
      board[:a2] = Piece.new(:rook, :black)
      board[:h1] = Piece.new(:rook, :black)

      expect(game.checkmate?).to eql(true)
    end
  end

  describe "#stalemate?" do
    it "returns true when player(white) is not in check but has no legal moves left" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 
      board[:h8] = Piece.new(:king, :white)
      board[:f7] = Piece.new(:queen, :black)
      board[:g6] = Piece.new(:king, :black)

      expect(game.stalemate?).to eql(true)
    end

    it "returns true when player(black) is not in check but has no legal moves left" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      game.current_player = p2
      board[:f8] = Piece.new(:king, :black)
      board[:f7] = Pawn.new(:white)
      board[:f6] = Piece.new(:king, :white)

      expect(game.stalemate?).to eql(true)
    end

    it "returns false when player(white) is not in check and has legal moves left" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:h8] = Piece.new(:king, :white)
      board[:f4] = Piece.new(:bishop, :white)
      board[:f7] = Piece.new(:queen, :black)
      board[:g6] = Piece.new(:king, :black)
      expect(game.stalemate?).to eql(false)
    end

    it "returns true when player(white) is not in check and has no legal moves left" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:h8] = Piece.new(:king, :white)
      board[:f7] = Piece.new(:queen, :black)
      board[:g6] = Piece.new(:king, :black)
      board[:f6] = Pawn.new(:white)
      board[:g5] = Pawn.new(:white)
      expect(game.stalemate?).to eql(false)
    end

    it "returns false when player(white) is not in check and has legal moves left" do
      board = Board.new
      board.clear
      p1, p2 = Player.new("p1", :white), Player.new("p2", :black)
      game = Game.new(board, p1, p2) 

      board[:h8] = Piece.new(:king, :white)
      board[:f7] = Piece.new(:queen, :black)
      board[:g6] = Piece.new(:king, :black)
      board[:h5] = Pawn.new(:white)
      expect(game.stalemate?).to eql(false)
    end

    it "returns true when white is unable to defend the king due to attack from multiple sources" do
      game = Game.load_test_state("checkmate")
      expect(game.checkmate?).to eql(true)
    end
  end

end
