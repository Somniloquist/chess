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

  def play
    puts("Type \"save\" at any point to save and quit.")
    puts("Type \"exit\" at any point to quit without saving.")
    puts board

    until game_over?
      loop do
        puts("TURN : #{current_player.color.to_s.upcase}")
        starting_cell = prompt_player_choice("Select a piece to move >> ")
        target_cell = prompt_player_choice("Select a target location >> ")
        # store origainal values in case the move needs to be reverted
        starting_cell_temp_value = board[starting_cell]
        target_cell_temp_value = board[target_cell]

        if make_play(starting_cell, target_cell)
          if promotion_possible?(target_cell)
            promotion_choice = get_promotion_choice
            promote_pawn(target_cell, promotion_choice)
          end

          # revert move if the move puts/leaves the king in check
          if player_in_check?
            board[starting_cell] = starting_cell_temp_value
            board[target_cell] = target_cell_temp_value
            puts("Illegal move, please try again.")
          else
            break
          end

        end
      end

      puts board
      swap_current_player
    end

    puts board
  end

  def make_play(start_cell, end_cell)
    piece_being_moved = board[start_cell]
    return false unless valid_play?(start_cell, end_cell)
    possible_moves = get_possible_moves(piece_being_moved, start_cell, end_cell)

    if play_is_castle?(start_cell, end_cell)
      return false unless castle_is_valid?(start_cell, end_cell)
      board[start_cell], board[end_cell] = board[end_cell], board[start_cell]
      move_rook_for_castle(get_rook_position_for_castle(end_cell))
    else
      return false unless possible_moves.size > 0 && possible_moves.include?(end_cell)
      # Knight can 'jump' over other pieces
      return false if move_obstructed?(start_cell, end_cell) unless piece_being_moved.type == :knight

      if piece_being_moved.is_a?(Pawn) && move_is_en_passant?(end_cell)
        move_piece(start_cell, end_cell)
        perform_en_passant
      elsif contains_enemy_piece?(end_cell)
        capture_piece(start_cell, end_cell)
      else
        move_piece(start_cell, end_cell)
      end
    end

    piece_being_moved.set_action_taken
    if piece_being_moved.is_a?(Pawn) && pawn_made_double_move?(start_cell, end_cell)
      capture_cell = get_en_passant_capture_cell(start_cell, end_cell)
      board.set_en_passant(capture_cell, end_cell)
    else
      board.clear_en_passant
    end

    end_cell
  end

  def self.load_state(file_name = "suspend")
    File.open("#{SAVE_FILE_DIR}/#{file_name}.yaml", "r") { |data| YAML::load(data) }
  end

  def self.load_test_state(file_name)
    File.open("./test_saves/#{file_name}.yaml", "r") { |data| YAML::load(data) }
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

    if piece.type == :pawn && (contains_enemy_piece?(end_cell) || (move_is_en_passant?(end_cell) && !end_cell.nil?))
      possible_moves = piece.capture_moves[0..-1] #duplicate piece move list
    else
      possible_moves = piece.moves[0..-1] #duplicate piece move list
      add_extra_pawn_move!(possible_moves, piece.color, position) if piece.type == :pawn
    end
      
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
    check_paths = enemy_paths.select { |path| path.include?(king_location)}

    # remove unnessary cells
    # rebuild the paths to only include paths that lead to the king's position
    check_paths.map! do |path|
      enemy_piece_starting_coordinate = path.first
      temp = get_move_path(enemy_piece_starting_coordinate, king_location).unshift(enemy_piece_starting_coordinate)
    end

    player_in_check? && king_moves.size == 0 && !king_can_be_defended?(king_location, check_paths, friendly_paths)  ? true : false
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
  def quit_game
    exit
  end

  def save_state(file_name = "suspend")
    yaml = YAML::dump(self)
    FileUtils.mkdir(SAVE_FILE_DIR) unless File.directory?(SAVE_FILE_DIR)
    File.open("#{SAVE_FILE_DIR}/#{file_name}.yaml", "w") {|save_file| save_file.puts(yaml)}
    puts("Game saved.")
  end

  def king_can_be_defended?(king_location, check_path, friendly_paths)
    check_path, friendly_paths = check_path.flatten, friendly_paths.flatten
    # remove king's location to prevent false positives
    friendly_paths.select! {|cell| cell != king_location}
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

  def contains_friendly_piece?(cell)
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
    return false unless board[cell].class == Symbol
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

  def prompt_player_choice(message)
    print message
    choice = gets.chomp.downcase.to_sym
    save_state if choice == :save
    quit_game if choice  == :exit
    choice
  end

  def game_over?
    if stalemate?
      puts("GAME OVER : STALEMATE")
      true
    elsif checkmate?
      puts("GAME OVER : CHECKMATE #{get_enemy_color.upcase} WINS")
      true
    else
      false
    end
  end

  def swap_current_player
    current_player == player1 ? @current_player = player2 : @current_player = player1
  end

  def play_is_castle?(start_cell, end_cell)
    king_start_positions = [:e1, :e8]
    possible_castle_moves = [:c1, :g1, :c8, :g8]
    return false unless board[start_cell].type == :king
    return false unless king_start_positions.include?(start_cell)
    return false unless possible_castle_moves.include?(end_cell)

    true
  end
  
  def get_rook_position_for_castle(end_cell)
   return :a1 if end_cell == :c1
   return :h1 if end_cell == :g1
   return :a8 if end_cell == :c8
   return :h8 if end_cell == :g8
  end

  def move_rook_for_castle(rook_position)
    case rook_position
    when :a1
      board[rook_position], board[:d1] = board[:d1], board[rook_position]
    when :h1
      board[rook_position], board[:f1] = board[:f1], board[rook_position]
    when :a8
      board[rook_position], board[:d8] = board[:d8], board[rook_position]
    when :h8
      board[rook_position], board[:f8] = board[:f8], board[rook_position]
    else
      puts "Woops, that's not supposed to happen. Illegal move."
    end
  end

  def path_under_attack?(friendly_path, enemy_path)
    friendly_path.each { |cell| return true if enemy_path.include?(cell) }
    false
  end

  def castle_is_valid?(start_cell, end_cell)
    king = board[start_cell]
    rook_position = get_rook_position_for_castle(end_cell)
    rook = board[rook_position]

    enemy_paths = get_all_possible_paths(get_enemy_color).flatten.uniq
    king_path = get_move_path(start_cell, end_cell)

    return false unless rook.type == :rook
    return false if player_in_check?
    return false if path_under_attack?(king_path, enemy_paths)
    return false if king.action_taken || rook.action_taken
    return false if move_obstructed?(start_cell, end_cell) || move_obstructed?(rook_position, end_cell)

    true
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

  def pawn_made_double_move?(start_cell, end_cell)
    (end_cell[1].to_i == start_cell[1].to_i + 2) || (end_cell[1].to_i == start_cell[1].to_i - 2)
  end

  def get_en_passant_capture_cell(start_cell, end_cell)
    if start_cell[1] < end_cell[1]
      capture_cell = "#{start_cell[0]}#{start_cell[1].to_i + 1}".to_sym
    else
      capture_cell = "#{start_cell[0]}#{start_cell[1].to_i - 1}".to_sym
    end
  end

  def perform_en_passant()
    board[board.en_passant[:pawn_cell]] = ''
  end
  
  def en_passant_possible?
    !board.en_passant.empty?
  end

  def move_is_en_passant?(end_cell)
    end_cell == board.en_passant[:capture_cell]
  end

end