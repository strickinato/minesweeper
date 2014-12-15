class Board

  attr_reader :size, :current_selection
  def initialize(size, bomb_count)
    @size = size
    @bomb_count = bomb_count
    @grid = create_grid
    select([0,0])

  end

  def create_grid
    random_bomb_locations = (0...(@size * @size)).to_a.sample(@bomb_count)

    Array.new(@size) do |i|
      Array.new(@size) do |j|
        Tile.new(self, [i, j], random_bomb_locations.include?(i * @size + j))
      end
    end
  end

  def display
    system("clear")

    output = @grid.map do |row|
      row.map do |tile|
        tile.selected? ? tile.to_s.on_white : tile.to_s
      end.join('')
    end.join("\n")

    puts output
    puts "WASD to move; 'f' to flag; 'r' to reveal; 'q' to save and quit"
  end


  def over?
    win? || lose?
  end

  def win?
    unflagged_bomb = false
    unrevealed_tile = false
    revealed_bomb = false
    flagged_non_bomb = false

    @grid.each do |row|
      row.each do |tile|
        flagged_non_bomb = true if !tile.bomb? && tile.flagged?
        revealed_bomb = true if tile.bomb? && tile.revealed?
        unflagged_bomb = true if tile.bomb? && !tile.flagged?
        unrevealed_tile = true if !tile.bomb? && !tile.revealed?
      end
    end

    if (!unflagged_bomb || !unrevealed_tile) && !revealed_bomb && !flagged_non_bomb
      return true
    end

    false
  end

  def lose?
    @grid.each do |row|
      row.each do |tile|
        return true if tile.bomb? && tile.revealed?
      end
    end
    false
  end


  def find_neighbors(pos)
    row, col = pos
    neighbors = []
    vectors = [[1, 1], [1, 0], [1, -1], [0, -1], [0, 1], [-1, -1], [-1, 0], [-1, 1]]
    vectors.each do |vector|
      new_row, new_col = row + vector.first, col + vector.last
      if (0...@size).cover?(new_row) && (0...@size).cover?(new_col)
        neighbors << @grid[new_row][new_col]
      end
    end
    neighbors
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, val)
    @grid[row][col] = val
  end

  def save_state
    f = File.open("saved_game", "w")
    f.puts self.to_yaml
    f.close
    true
  end

  def select(new_pos)
    row, col = new_pos
    col = col % @size if col >= @size
    row = row % @size if row >= @size

    @current_selection.select if @current_selection
    @current_selection = self[row, col]
    @current_selection.select
  end

end
