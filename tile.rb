class Tile
  attr_reader :pos

  def initialize(board, pos, bomb)
    @pos = pos
    @board = board
    @revealed = false
    @bomb = bomb
    @flagged = false
    @selected = false
  end

  def to_s
    if !revealed? && !flagged?
      return "   ".on_red
    elsif flagged?
      return " \u05d0 ".encode('utf-8').on_red
    elsif revealed? && !bomb?
      return " #{neighbor_bombs} ".on_green
    elsif bomb?
      "[X]"
    else
      raise DisplayError
    end


  end

  def neighbor_bombs
    @board.find_neighbors(@pos).count { |neighbor| neighbor.bomb? }
  end

  def bomb?
    @bomb
  end

  def flagged?
    @flagged
  end

  def revealed?
    @revealed
  end

  def selected?
    @selected
  end

  def select
    @selected = !@selected
  end

  def reveal
    @revealed = true
    if neighbor_bombs == 0
      neighbors = @board.find_neighbors(@pos).each do |neighbor|
        neighbor.reveal unless neighbor.revealed?
      end
    end
  end

  def flag
    @flagged = !@flagged
  end

end
