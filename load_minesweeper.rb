require './minesweeper.rb'
require './tile.rb'
require './board.rb'

if $PROGRAM_NAME == __FILE__
  game = Minesweeper.new
  game.play_gui
end
