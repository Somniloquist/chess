class Game
  attr_reader :board
  def initialize(board, player1, player2)
    @board = board
    @player1, @player2 = player1, player2
  end

  def move_piece(starting, ending)
    board[starting], board[ending] = board[ending], board[starting]
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
end