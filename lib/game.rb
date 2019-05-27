class Game
  attr_accessor :current_player
  attr_reader :board, :player1, :player2
  def initialize(board, player1, player2)
    @board = board
    @player1, @player2 = player1, player2
    @current_player = player1 # white player goes first
  end
  
  def make_play(start_cell, end_cell)
    return false unless board[start_cell].class <= Piece
    return false unless board[start_cell] && board[end_cell] # cell exists
    return false unless board[start_cell].color == current_player.color
    possible_moves = get_possible_moves(board[start_cell], start_cell, end_cell)
    return false unless possible_moves.size > 0 && possible_moves.include?(end_cell)

    # Knight can 'jump' over other pieces
    return false if move_obstructed?(start_cell, end_cell) unless board[start_cell].type == :knight

    if contains_enemy_piece?(end_cell)
      capture_piece(start_cell, end_cell)
    else
      move_piece(start_cell, end_cell)
    end

    end_cell
  end

  # returns direct path(all cells) between start(exclusive) and end_cell(inclusive)
  def get_move_path(start_cell, end_cell)
    start_coordinates = board.chess_notation_to_coordinates(start_cell)
    end_coordinates = board.chess_notation_to_coordinates(end_cell)
    start_y, start_x = start_coordinates[0], start_coordinates[1]
    end_y, end_x = end_coordinates[0], end_coordinates[1]
    path = []

    if horizonal_move?(start_cell, end_cell)
      path = build_horizonal_path(start_y, start_x, end_y, end_x)
    elsif vertical_move?(start_cell, end_cell)
      path = build_vertical_path(start_y, start_x, end_y, end_x)
    else
      path = build_diagonal_path(start_y, start_x, end_y, end_x)
    end
    path.map { |coordinates| board.coordinates_to_chess_notation(coordinates) }
  end

  # returns possible moves for a piece, does not check for obstructions
  def get_possible_moves(piece, position, end_cell = nil)
    position = board.chess_notation_to_coordinates(position)

    if piece.type == :pawn && contains_enemy_piece?(end_cell)
      possible_moves = piece.capture_moves[0..-1] #duplicate piece move list
    else
      possible_moves = piece.moves[0..-1] #duplicate piece move list
      add_extra_pawn_move!(possible_moves, piece.color, position) if piece.type == :pawn
    end
    possible_moves.map! { |y,x| [y+position[0], x+position[1]] }
    possible_moves.select! { |coordinates| valid_move?(coordinates) }

    possible_moves.map { |coordinates| board.coordinates_to_chess_notation(coordinates) }
  end

  #
  def get_possible_pawn_capture_moves(piece, position)
    position = board.chess_notation_to_coordinates(position)

    possible_moves = piece.capture_moves[0..-1] #duplicate piece move list
    possible_moves.map! { |y,x| [y+position[0], x+position[1]] }
    possible_moves.select! { |coordinates| valid_move?(coordinates) }

    possible_moves.map { |coordinates| board.coordinates_to_chess_notation(coordinates) }
  end

  def king_in_check?(location_of_king, paths)
    return false if paths.nil?
    paths.include?(location_of_king) ? true : false
  end

  # get chess notation location of the king (of provided color)
  def get_king_location(color)
    board.grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell.class <= Piece
          return board.coordinates_to_chess_notation([y,x]) if cell.type == :king && cell.color == color
        end
      end
    end
  end

  def get_all_possible_paths(color)
    paths = []
    moves = []

    board.grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell.class <= Piece
          next if cell.color != color
          cell_location = board.coordinates_to_chess_notation([y,x])
          if cell.type == :pawn
            moves = get_possible_pawn_capture_moves(cell, cell_location)
          else
            moves = get_possible_moves(cell, cell_location)
          end
          cell.type == :knight ? paths << moves : moves.each { |move | paths << get_move_path(cell_location, move) unless move_obstructed?(cell_location, move) }
        end
      end
    end

    paths.flatten.uniq
  end

  private
  def contains_piece?(cell)
    board[cell].class <= Piece ? true : false
  end

  def contains_enemy_piece?(cell)
    board[cell].class <= Piece && board[cell].color != current_player.color ? true : false
  end

  def move_piece(starting, ending)
    board[starting], board[ending] = board[ending], board[starting]
  end

  def capture_piece(starting, ending)
    board[starting], board[ending] = "", board[starting]
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

  def move_obstructed?(start_cell, end_cell)
    # disregard the destination cell when the intent is to capture an enemy piece
    contains_enemy_piece?(end_cell) ? path = get_move_path(start_cell, end_cell)[0...-1] : path = get_move_path(start_cell, end_cell)
    path.each { |cell| return true unless board.empty?(cell) }
    false
  end

  def valid_move?(coordinates)
    coordinates.all? {|value| value.between?(0,7)}
  end

  def build_diagonal_path(start_y, start_x, end_y, end_x)
    if end_y > start_y && end_x < start_x
      Array.new((start_y - end_y ).abs) { |i| [start_y + i + 1, start_x - i - 1]  }
    elsif end_y < start_y && end_x > start_x
      Array.new((start_y - end_y ).abs) { |i| [start_y - i - 1, start_x + i + 1]  }
    elsif end_y > start_y && end_x > start_x
      Array.new((start_x - end_x).abs) { |i| [start_y + i + 1, start_x + i + 1]  }
    elsif end_y < start_y && end_x < start_x
      Array.new((start_y - end_y).abs) { |i| [start_y - i - 1, start_x - i - 1]  }
    end
  end

  def add_extra_pawn_move!(possible_moves, color, position)
    return possible_moves unless position[0] == 1 || position[0] == 6
    case color
    when :white
      possible_moves << [2,0]
    when :black
      possible_moves << [-2,0]
    end
  end
  
end