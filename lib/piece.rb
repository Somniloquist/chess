require_relative "chess_helpers.rb"

class Piece
  include ChessPieceSymbols
  include ChessPieceMoveList
  attr_reader :type, :color, :action_taken

  def initialize(type, color)
    @type = type
    @color = color
    @action_taken = false
  end

  def set_action_taken
    @action_taken = true
  end

  def moves
    MOVES[type]
  end

  def symbol
    SYMBOLS[(type.to_s + color.to_s).to_sym]
  end
end

# create a seperate pawn class to keep track of the pawn's state (if it has moved or not) and direction of it's moves
class Pawn < Piece
  def initialize(color)
    @type = :pawn
    @color = color
    @action_taken = false
  end

  def set_action_taken
    @action_taken = true
  end

  def moves
    # game#get_possible_moves requires a nested array
    case color
    when :white
      [[1,0]]
    when :black
      [[-1,0]]
    end
  end

  def capture_moves
    case color
    when :white
      [[1,1], [1,-1]]
    when :black
      [[-1,-1], [-1, 1]]
    end
  end

end