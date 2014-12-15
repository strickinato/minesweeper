require 'yaml'
require 'colorize'
require 'io/console'

class DisplayError < RuntimeError
end
class InputError < RuntimeError
end

class Minesweeper


  def play
    load_game

    until @board.over?

      @board.display
      action = take_action
      if action == 's'
        break if save_and_quit
      end
      coord = take_coord
      change_board(action, coord)
    end
    display_result
  end

  def play_gui
    load_game

    until @board.over?

      @board.display
      action = get_keypress
      if action == "q"
        save_and_quit
        break
      end
      take_action_gui(action)
    end
    display_result
  end

  def get_keypress
    opts = ['q','r','f','w','a','s','d']
    key = STDIN.getch
    until opts.include?(key)
      key = STDIN.getch
    end
    key
  end

  def take_action_gui(action)
    cur_row, cur_col = @board.current_selection.pos

    case action
    when "r"
      @board.current_selection.reveal
    when "f"
      @board.current_selection.flag
    when "w"
      @board.select([cur_row - 1, cur_col])
    when "a"
      @board.select([cur_row, cur_col - 1])
    when "s"
      @board.select([cur_row + 1, cur_col])
    when "d"
      @board.select([cur_row, cur_col + 1])
    end

  end

  def display_result
    puts @board.display if @board.over?
    system("clear")
    puts %q{yaya} if @board.win?
    puts %q{               ____  , -- -        ---   -.
            (((   ((  ///   //   '  \\-\ \  )) ))
        ///    ///  (( _        _   -- \\--     \\\ \)
     ((( ==  ((  -- ((             ))  )- ) __   ))  )))
      ((  (( -=   ((  ---  (          _ ) ---  ))   ))
         (( __ ((    ()(((  \\  / ///     )) __ )))
                \\_ (( __  |     | __  ) _ ))
                          ,|  |  |
                         `-._____,-'
                         `--.___,--'
                           |     |
                           |    ||
                           | ||  |
                 ,    _,   |   | |
        (  ((  ((((  /,| __|     |  ))))  )))  )  ))
      (()))       __/ ||(    ,,     ((//\     )     ))))
---((( ///_.___ _/    ||,,_____,_,,, (|\ \___.....__..  ))--ool
           ____/      |/______________| \/_/\__
          /                                \/_/|
         /  |___|___|__                        ||     ___
         \    |___|___|_                       |/\   /__/|
         /      |   |                           \/   |__|/     } if @board.lose?
  end

  def save_and_quit
    if @board.save_state
      puts "Game saved!"
      return true
    end
    false
  end

  def load_game
    system("clear")
    responses = ['n','new','l','load']
    puts "Start a new game? Or load last saved game? (n,l)"
      begin
        action = gets.chomp.downcase.strip
      raise InputError unless responses.include?(action)
      rescue InputError
        "Enter l or n"
        retry
      end

      if action == 'n'
        @board = Board.new(9, 9)
      else
        f = File.read('saved_game')
        @board = YAML.load(f)
      end
  end

  def change_board(action, coord)
    row, col = coord
     if action == 'r'
       @board[row, col].reveal
     elsif action == 'f'
       @board[row, col].flag
     end
  end

  def take_coord
    puts "Put in the coordinate!"
    begin
      guess = gets.chomp
      unless guess.match(/^\s*\d{1,2}\s*,\s*\d{1,2}\s*$/)
        raise InputError.new("Please write digits, separted by a comma")
      end
      coord = guess.split(",").map { |char| char.to_i - 1 }
      range = (0...@board.size)
      unless range.cover?(coord.first) && range.cover?(coord.last)
        raise InputError.new("That's not on the board!")
      end
    rescue InputError => e
      puts e
      retry
    end
    coord
  end

  def take_action
    responses = ['r', 'reveal', 'f', 'flag', 's', 'save']
    puts "Do you want to reveal or flag a space or save? (r, f, s)"
    begin
      action = gets.chomp.downcase.strip
    raise InputError unless responses.include?(action)
    rescue InputError
      "Enter f, r, or s"
      retry
    end
    action[0]
  end


end



if $PROGRAM_NAME == __FILE__
   game = Minesweeper.new
   game.play_gui
end
