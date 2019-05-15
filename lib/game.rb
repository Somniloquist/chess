class Game
  attr_accessor :current_player
  attr_reader :board, :player1, :player2
  def initialize(board, player1, player2)
    @board = board
    @player1, @player2 = player1, player2
    @current_player = player1 # white player goes first
  end

  def make_play(starting, ending)
    return false unless board[starting].class <= Piece
    return false unless board[starting] && board[ending] # cell exists
    return false unless board[starting].color == current_player.color
    return false unless get_possible_moves(board[starting], starting).size > 0

    move_piece(starting, ending)
    ending
  end

  def valid_move?(coordinates)
    coordinates.all? {|value| value.between?(0,7)}
  end

  def get_possible_moves(piece, position)
    position = board.chess_notation_to_coordinates(position)
    possible_moves = piece.moves[0..-1] #duplicate piece move list
    possible_moves.map! { |y,x| [y+position[0], x+position[1]] }
    possible_moves.select! { |coordinates| valid_move?(coordinates) }
    possible_moves.map { |coordinates| board.coordinates_to_chess_notation(coordinates) }
  end
  
  def get_move_path(start_cell, end_cell)
    start_coordinate = board.chess_notation_to_coordinates(start_cell)
    end_coordinate = board.chess_notation_to_coordinates(end_cell)

    # TODO: split this mess into smaller functions
    if horizonal_move?(start_cell, end_cell)
      if start_coordinate[1] < end_coordinate[1]
        Array.new((start_coordinate[1] - end_coordinate[1]).abs) { |i| [start_coordinate[0], i + start_coordinate[1] + 1] }
      else
        Array.new((end_coordinate[1] - start_coordinate[1]).abs) { |i| [end_coordinate[0], (i + end_coordinate[1] + 1)] }.reverse
      end
    elsif vertical_move?(start_cell, end_cell)
      if start_coordinate[0] < end_coordinate[0]
        Array.new((start_coordinate[0] - end_coordinate[0]).abs) { |i| [i + start_coordinate[0] + 1, start_coordinate[1]] }
      else
        Array.new((end_coordinate[0] - start_coordinate[0]).abs) { |i| [(i + end_coordinate[0] + 1), end_coordinate[1]] }.reverse
      end
    else # assume diagonal move
    end
  end

  def horizonal_move?(start_cell, end_cell)
    start_cell[1] == end_cell[1]
  end

  def vertical_move?(start_cell, end_cell)
    start_cell[0] == end_cell[0]
  end

  private
  def move_piece(starting, ending)
    board[starting], board[ending] = board[ending], board[starting]
  end


end