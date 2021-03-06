require_relative "chess_helpers.rb"

class Board
  include ChessNotation
  attr_reader :grid, :en_passant
  def initialize(columns=8, rows=8)
    @grid = Array.new(columns) {Array.new(rows, "")}
    @en_passant = {}
    initialize_pieces
  end

  def set_en_passant(capture_cell, pawn_cell)
    @en_passant[:capture_cell] = capture_cell
    @en_passant[:pawn_cell] = pawn_cell
  end

  def clear_en_passant()
    @en_passant = {}
  end

  def [](key)
    return nil unless positions.include?(key)
    position = chess_notation_to_coordinates(key)
    grid[position.first][position.last]
  end

  def []=(key, value)
    return nil unless positions.include?(key)
    position = chess_notation_to_coordinates(key)
    grid[position.first][position.last] = value
  end
  
  def empty?(cell)
    self[cell] == "" ? true : false
  end

  def clear
    @grid.each_with_index do |row, row_index|
      row.each_with_index {|col, col_index| @grid[row_index][col_index] = ""}
    end
  end

  def positions
    POSITIONS
  end

  def to_s
    output = "\n   "
    grid.size.times { output << "######" }
    output << "#\n"

    grid.reverse_each_with_index do |row, i|
      output << " #{i+1} "
      row.each do |cell|
        cell.class <= Piece ? output << "#  #{cell.symbol}  " : output << "#     "
      end

      output << "#\n   "
      grid.size.times { output << "######" }
      output << "#\n"

    end
    output << "      A     B     C     D     E     F     G     H\n   "
  end

  private
  def initialize_pieces
    8.times { |i| grid[1][i] = Pawn.new(:white)}
    grid[0][0] = Piece.new(:rook, :white)
    grid[0][7] = Piece.new(:rook, :white)
    grid[0][6] = Piece.new(:knight, :white)
    grid[0][1] = Piece.new(:knight, :white)
    grid[0][5] = Piece.new(:bishop, :white)
    grid[0][2] = Piece.new(:bishop, :white)
    grid[0][4] = Piece.new(:king, :white)
    grid[0][3] = Piece.new(:queen, :white)

    8.times { |i| grid[-2][i] = Pawn.new(:black)}
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

