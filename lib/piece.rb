class Piece
  @@MOVES =  {
    knight: [[-1,2],[-2,1],[2,1],[1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]]
  }
  attr_reader :type, :color
  def initialize(type, color)
    @type = type
    @color = color
  end

  def moves
    @@MOVES[type]
  end
end