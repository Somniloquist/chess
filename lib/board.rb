module ChessNotation
  # convert chess notation to y,x positions
  POSITIONS = {:A1=>[0, 0], :A2=>[1, 0], :A3=>[2, 0], :A4=>[3, 0], :A5=>[4, 0], :A6=>[5, 0], :A7=>[6, 0], :A8=>[7, 0], :B1=>[0, 1], :B2=>[1, 1], :B3=>[2, 1], :B4=>[3, 1], :B5=>[4, 1], :B6=>[5, 1], :B7=>[6, 1], :B8=>[7, 1], :C1=>[0, 2], :C2=>[1, 2], :C3=>[2, 2], :C4=>[3, 2], :C5=>[4, 2], :C6=>[5, 2], :C7=>[6, 2], :C8=>[7, 2], :D1=>[0, 3], :D2=>[1, 3], :D3=>[2, 3], :D4=>[3, 3], :D5=>[4, 3], :D6=>[5, 3], :D7=>[6, 3], :D8=>[7, 3], :E1=>[0, 4], :E2=>[1, 4], :E3=>[2, 4], :E4=>[3, 4], :E5=>[4, 4], :E6=>[5, 4], :E7=>[6, 4], :E8=>[7, 4], :F1=>[0, 5], :F2=>[1, 5], :F3=>[2, 5], :F4=>[3, 5], :F5=>[4, 5], :F6=>[5, 5], :F7=>[6, 5], :F8=>[7, 5], :G1=>[0, 6], :G2=>[1, 6], :G3=>[2, 6], :G4=>[3, 6], :G5=>[4, 6], :G6=>[5, 6], :G7=>[6, 6], :G8=>[7, 6], :H1=>[0, 7], :H2=>[1, 7], :H3=>[2, 7], :H4=>[3, 7], :H5=>[4, 7], :H6=>[5, 7], :H7=>[6, 7], :H8=>[7, 7]}

  def chess_notation_to_coordinates(board_position)
    POSITIONS[board_position]
  end

  def coordinates_to_chess_notation(coordinates)
    POSITIONS.find { |key, value| value == coordinates }.first
  end

end

class Board
  include ChessNotation
  attr_reader :grid
  def initialize(columns=8, rows=8)
    @grid = Array.new(columns) {Array.new(rows, "")}
    initialize_pieces
  end

  def [](key)
    position = chess_notation_to_coordinates(key)
    grid[position.first][position.last]
  end

  def []=(key, value)
    position = chess_notation_to_coordinates(key)
    grid[position.first][position.last] = value
  end

  # return a cell's contents using chess notation
  def cell(key)
    position = chess_notation_to_coordinates(key)
    grid[position[0]][position[1]]
  end

  def move_piece(starting_cell, ending_cell)
    piece = cell(starting_cell)
    starting_coordinates = chess_notation_to_coordinates(starting_cell)
    ending_coordinates = chess_notation_to_coordinates(ending_cell)
    grid
  end

  def to_s
    output = "\n   "
    grid.size.times { output << "######" }
    output << "#\n"

    grid.reverse_each_with_index do |row, i|
      output << " #{i+1} "
      row.each do |cell|
        cell.class == Piece ? output << "#  #{cell.symbol}  " : output << "#     "
      end

      output << "#\n   "
      grid.size.times { output << "######" }
      output << "#\n"

    end
    output << "      A     B     C     D     E     F     G     H\n   "
  end

  private
  def initialize_pieces
    8.times { |i| grid[1][i] = Piece.new(:pawn, :white)}
    grid[0][0] = Piece.new(:rook, :white)
    grid[0][7] = Piece.new(:rook, :white)
    grid[0][6] = Piece.new(:knight, :white)
    grid[0][1] = Piece.new(:knight, :white)
    grid[0][5] = Piece.new(:bishop, :white)
    grid[0][2] = Piece.new(:bishop, :white)
    grid[0][4] = Piece.new(:king, :white)
    grid[0][3] = Piece.new(:queen, :white)

    8.times { |i| grid[-2][i] = Piece.new(:pawn, :black)}
    grid[-1][0] = Piece.new(:rook, :black)
    grid[-1][7] = Piece.new(:rook, :black)
    grid[-1][6] = Piece.new(:knight, :black)
    grid[-1][1] = Piece.new(:knight, :black)
    grid[-1][5] = Piece.new(:bishop, :black)
    grid[-1][2] = Piece.new(:bishop, :black)
    grid[-1][4] = Piece.new(:king, :black)
    grid[-1][3] = Piece.new(:queen, :black)
  end
end

# shamelessly copied from https://stackoverflow.com/a/20248507
# used to print board in standard chess style
class Array
  def reverse_each_with_index &block
    (0...length).reverse_each do |i|
      block.call self[i], i
    end
  end
end

# converts chess notation into array [y,x] coordinates
# positions = {}
# rows = "ABCDEFGH".split("")
# columns = 8

# rows.each_with_index do |row, row_i|
#   columns.times do |column_i|
#     key = "#{row}#{column_i + 1}".to_sym
#     positions[key] = [column_i, row_i]
#   end
# end