#!/usr/bin/env ruby
require "./lib/board.rb"
require "./lib/piece.rb"
require "./lib/player.rb"
require "./lib/game.rb"

puts("Welcome to Chess.rb")
puts("Would you like to load your previous game? [y/n]")
print(" >> ")
choice = gets.chomp.downcase

case choice
when "y"
  Game.load_state.play
else
  puts("Starting a new game.")
  player1, player2 = Player.new("Player1", :white), Player.new("Player2", :black)
  board = Board.new
  game = Game.new(board, player1, player2)
  game.play
end
