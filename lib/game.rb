require "yaml"
require "fileutils"
SAVE_FILE_DIR = "./save/"

class Game
  attr_accessor :current_player
  attr_reader :board, :player1, :player2
  def initialize(board, player1, player2)
    @board = board
    @player1, @player2 = player1, player2
    @current_player = player1 # white player goes first
  end

  def make_play(start_cell, end_cell)
    return false unless valid_play?(start_cell, end_cell)
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

  def self.load_state(file_name = "autosave")
    File.open("#{SAVE_FILE_DIR}/#{file_name}.yaml", "r") { |data| YAML::load(data) }
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

  # Workaround used to find checkmate (get_all_possible_paths requires a destination cell
  # to determine if the pawn is capturing)
  def get_possible_pawn_capture_moves(piece, position)
    position = board.chess_notation_to_coordinates(position)

    possible_moves = piece.capture_moves[0..-1] #duplicate piece move list
    possible_moves.map! { |y,x| [y+position[0], x+position[1]] }
    possible_moves.select! { |coordinates| valid_move?(coordinates) }

    possible_moves.map { |coordinates| board.coordinates_to_chess_notation(coordinates) }
  end

  def player_in_check?
    location_of_king = get_king_location(current_player.color)
    enemy_paths = get_all_possible_paths(get_enemy_color)
    return false if enemy_paths.nil?
    enemy_paths.flatten.include?(location_of_king) ? true : false
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
          if cell.type == :knight 
            paths << moves 
          else
            path = []
            moves.each do |move| 
              path << get_move_path(cell_location, move) unless move_obstructed?(cell_location, move, true)
            end
            path.unshift(cell_location)
            paths << path.flatten.uniq
          end
        end
      end
    end

    paths
  end

  def trim_king_moves(king_moves, enemy_moves)
    king_moves.select { |king_move| !enemy_moves.flatten.include?(king_move) }
  end

  def checkmate?
    king_location = get_king_location(current_player.color)
    king = board[king_location]
    enemy_color = get_enemy_color
    king_moves = get_possible_moves(king, king_location)
    enemy_paths = get_all_possible_paths(enemy_color)
    king_moves = trim_king_moves(king_moves, enemy_paths)

    # check if a friendly piece can "block" the attack
    friendly_paths = get_all_possible_paths(current_player.color)
    # remove friendly kings paths (first element of each path is the origin of that path)
    friendly_paths.select! { |path| path[0] != king_location}
    check_path = enemy_paths.select { |path| path.include?(king_location)}
    check_path.map! { |path| path[0..path.index(king_location)] }

    player_in_check? && king_moves.size == 0 && !king_can_be_defended?(king_location, check_path, friendly_paths)  ? true : false
  end

  def stalemate?
    location_of_king = get_king_location(current_player.color)
    enemy_paths = get_all_possible_paths(get_enemy_color)
    king_moves = get_possible_moves(board[location_of_king], location_of_king)

    king_legal_moves = trim_king_moves(king_moves, enemy_paths)

    return true if !player_in_check? && king_legal_moves.size == 0 && !player_has_legal_move?
    false
  end






  private
  def save_state(file_name = "autosave")
    yaml = YAML::dump(self)
    FileUtils.mkdir(SAVE_FILE_DIR) unless File.directory?(SAVE_FILE_DIR)
    File.open("#{SAVE_FILE_DIR}/#{file_name}.yaml", "w") {|save_file| save_file.puts(yaml)}
    puts("Game saved.")
  end

  def king_can_be_defended?(king_location, check_path, friendly_paths)
    check_path, friendly_paths = check_path.flatten, friendly_paths.flatten
    return false if check_path.count(king_location) > 1
    return false if friendly_paths.size <= 0
    friendly_paths.each { |cell| return true if check_path.include?(cell) }
    false
  end

  def get_enemy_color
    current_player.color == :white ? :black : :white
  end
  
  def contains_piece?(cell)
    board[cell].class <= Piece ? true : false
  end

  def contains_colored_piece?(cell, color)
    board[cell].class <= Piece && board[cell].color == current_player.color ? true : false
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

  def move_obstructed?(start_cell, end_cell, check=false)
    # some excepting when testing for checkmate
    if check
      contains_piece?(end_cell) ? path = get_move_path(start_cell, end_cell)[0...-1] : path = get_move_path(start_cell, end_cell)
      path.each { |cell| return true unless board.empty?(cell) || board[cell].type == :king }
    else
      # disregard the destination cell when the intent is to capture an enemy piece
      contains_enemy_piece?(end_cell) ? path = get_move_path(start_cell, end_cell)[0...-1] : path = get_move_path(start_cell, end_cell)
      path.each { |cell| return true unless board.empty?(cell) }
    end
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

  def promotion_possible?(cell)
    board[cell].type == :pawn && (cell[1] == "1" || cell[1] == "8")
  end

  def get_promotion_choice
    promotion_choices = [:queen, :rook, :bishop, :knight].freeze
    puts("Your pawn is ready for promotion. Choose a new piece from the list (select a number).")
    puts("[0] => queen, [1] => rook, [2] => bishop, [3] => knight")
    loop do
      print(" >> ")
      choice = gets.chomp.to_i
      return promotion_choices[choice] if choice.between?(0, promotion_choices.size - 1)
    end
  end

  # 'promotion' should be a symbol (ie. :queen, :knight etc.)
  def promote_pawn(cell, promotion)
    pawn = board[cell]
    board[cell] = Piece.new(promotion, pawn.color)
  end

  def piece_has_legal_move?(cell)
    piece = board[cell]
    moves = get_possible_moves(piece, cell)
    moves.each { |move| return true unless move_obstructed?(cell, move)}
    false
  end

  def player_has_legal_move?(color = current_player.color)
    piece_locations = get_location_of_all_pieces(color)
    # ignore the king, function does not check for king's moves
    piece_locations.delete(get_king_location(color))
    piece_locations.each { |cell| return true if piece_has_legal_move?(cell) }
    false
  end

  def get_location_of_all_pieces(color)
    pieces = []
    board.grid.each_with_index do |row, y|
      row.each_with_index { |cell, x| pieces << board.coordinates_to_chess_notation([y,x]) if cell.class <= Piece && cell.color == color }
    end
    pieces
  end

  def valid_play?(start_cell, end_cell)
    return false unless board[start_cell].class <= Piece
    return false unless board[start_cell] && board[end_cell] # cell exists
    return false unless board[start_cell].color == current_player.color
    true
  end

  
end