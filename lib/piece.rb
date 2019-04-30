class Piece
  @@MOVES =  {
    knight: [[-1,2],[-2,1],[2,1],[1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]]
  }
  @@SYMBOLS = {
    kingwhite: "\u2654",
    queenwhite: "\u2655",
    rookwhite: "\u2656",
    bishopwhite: "\u2657",
    knightwhite: "\u2658",
    pawnwhite: "\u2659",
    kingblack: "\u265A",
    queenblack: "\u265B",
    rookblack: "\u265C",
    bishopblack: "\u265D",
    knightblack: "\u265E",
    pawnblack: "\u265F"
  }

  attr_reader :type, :color
  def initialize(type, color)
    @type = type
    @color = color
  end

  def moves
    @@MOVES[type]
  end

  def symbol
    @@SYMBOLS[(type.to_s + color.to_s).to_sym]
  end
end