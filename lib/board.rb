class Board
  attr_reader :grid
  def initialize(col, row)
    @grid = Array.new(col) {Array.new(row, "")}
  end

  def to_s
    output = "\n   "
    output << "   a     b     c     d     e     f     g     h\n   "
    grid.size.times { output << "######" }
    output << "#\n"

    grid.each_with_index do |row, i|
      output << " #{i+1} "
      row.each do |cell|
        cell.empty? ? output << "#     " : output << "#  #{cell.name}  "
      end

      output << "#\n   "
      grid.size.times { output << "######" }
      output << "#\n"

    end
    output << "\n"
  end

end