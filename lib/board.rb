class Board
  attr_reader :grid
  def initialize(col, row)
    @grid = Array.new(col) {Array.new(row, " ")}
  end

  def to_s
    output = ""
    output << "\n"
    grid.each do |row|
      output << row.to_s + "\n"
    end
    output << "\n"
  end

end