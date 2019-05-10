class Game
  attr_accessor :current_player
  attr_reader :board, :player1, :player2
  def initialize(board, player1, player2)
    @board = board
    @player1, @player2 = player1, player2
    @current_player = player1
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

  private
  def move_piece(starting, ending)
    board[starting], board[ending] = board[ending], board[starting]
  end

end