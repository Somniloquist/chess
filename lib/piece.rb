require_relative "chess_helpers.rb"

class Piece
  include ChessPieceSymbols
  include ChessPieceMoveList
  attr_reader :type, :color

  def initialize(type, color)
    @type = type
    @color = color
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
  end

  def moves
    case color
    when :white
      [1,0]
    when :black
      [-1,0]
    end
  end

end