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
    start_coordinates = board.chess_notation_to_coordinates(start_cell)
    end_coordinates = board.chess_notation_to_coordinates(end_cell)
    start_y, start_x = start_coordinates[0], start_coordinates[1]
    end_y, end_x = end_coordinates[0], end_coordinates[1]

    if horizonal_move?(start_cell, end_cell)
      build_horizonal_path(start_y, start_x, end_y, end_x)
    elsif vertical_move?(start_cell, end_cell)
      build_vertical_path(start_y, start_x, end_y, end_x)
    else
      build_diagonal_path(start_y, start_x, end_y, end_x)
    end
  end
  
  private
  def move_piece(starting, ending)
    board[starting], board[ending] = board[ending], board[starting]
  end

  def horizonal_move?(start_cell, end_cell)
    start_cell[1] == end_cell[1]
  end

  def vertical_move?(start_cell, end_cell)
    start_cell[0] == end_cell[0]
  end

  def build_horizonal_path(start_y, start_x, end_y, end_x)
    if start_x < end_x
      Array.new((start_x - end_x).abs) { |i| [start_y, start_x + i + 1] }
    else
      Array.new((start_x - end_x).abs) { |i| [start_y, start_x - i - 1] }
    end
  end

  def build_vertical_path(start_y, start_x, end_y, end_x)
    if start_y < end_y
      Array.new((start_y - end_y).abs) { |i| [start_y + i + 1, start_x] }
    else
      Array.new((start_y - end_y).abs) { |i| [start_y - i - 1, start_x] }
    end
  end

  def build_diagonal_path(start_y, start_x, end_y, end_x)
    if end_y > start_y && end_x < start_x
      Array.new((start_y - end_y ).abs) { |i| [start_y + i + 1, start_x - i - 1]  }
    elsif end_y < start_y && end_x > start_x
      Array.new((start_y - end_y ).abs) { |i| [start_y - i - 1, start_x + i + 1]  }
    elsif end_y && end_x > start_y && start_x
      Array.new((start_x - end_x).abs) { |i| [start_y + i + 1, start_y + i + 1]  }
    elsif end_y && end_x < start_y && start_x
      Array.new((start_y - end_y).abs) { |i| [start_y - i - 1, start_y - i - 1]  }
    end
  end

end