class Board
  attr_reader :grid
  def initialize(col, row)
    @grid = Array.new(col) {Array.new(row, " ")}
  end

end