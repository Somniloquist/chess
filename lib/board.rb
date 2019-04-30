class Board
  attr_reader :grid
  def initialize(columns=8, rows=8)
    @grid = Array.new(columns) {Array.new(rows, "")}
    set_pieces(columns, rows)
  end

  def to_s
    output = "\n   "
    output << "   a     b     c     d     e     f     g     h\n   "
    grid.size.times { output << "######" }
    output << "#\n"

    grid.each_with_index do |row, i|
      output << " #{i+1} "
      row.each do |cell|
        cell.class == Piece ? output << "#  #{cell.symbol}  " : output << "#     "
      end

      output << "#\n   "
      grid.size.times { output << "######" }
      output << "#\n"

    end
    output << "\n"
  end

  private
  def set_pieces(columns, rows)
    columns.times { |i| grid[1][i] = Piece.new(:pawn, :white)}
    grid[0][0] = Piece.new(:rook, :white)
    grid[0][7] = Piece.new(:rook, :white)
    grid[0][6] = Piece.new(:knight, :white)
    grid[0][1] = Piece.new(:knight, :white)
    grid[0][5] = Piece.new(:bishop, :white)
    grid[0][2] = Piece.new(:bishop, :white)
    grid[0][4] = Piece.new(:king, :white)
    grid[0][3] = Piece.new(:queen, :white)

    columns.times { |i| grid[-2][i] = Piece.new(:pawn, :black)}
    grid[7][0] = Piece.new(:rook, :black)
    grid[7][7] = Piece.new(:rook, :black)
    grid[7][6] = Piece.new(:knight, :black)
    grid[7][1] = Piece.new(:knight, :black)
    grid[7][5] = Piece.new(:bishop, :black)
    grid[7][2] = Piece.new(:bishop, :black)
    grid[7][4] = Piece.new(:king, :black)
    grid[7][3] = Piece.new(:queen, :black)
  end
end