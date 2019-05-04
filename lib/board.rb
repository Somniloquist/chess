require_relative "chess_helpers.rb"

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

