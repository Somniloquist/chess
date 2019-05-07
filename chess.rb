#!/usr/bin/env ruby
require "./lib/board.rb"
require "./lib/piece.rb"
require "./lib/player.rb"

player1, player2 = Player.new("Player 1", :white), Player.new("Player 2", :black)
board = Board.new

puts board
