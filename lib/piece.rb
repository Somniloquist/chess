require "chess_helpers.rb"

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