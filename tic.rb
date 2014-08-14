class Board
  attr_accessor :grids
  
  def initialize
    @grids = Array.new(3){ Array.new(3, "-")}
  end
  
  def won?
    !winner.nil?
  end
  
  def winner
    (@grids + cols+ diagonals).each do |trio|
      return :x if trio == [:x, :x, :x]
      return :o if trio == [:o, :o, :o]
    end
    nil
  end

  def empty?(pos)
    return true if self[pos] == "-"  
    return false
  end

  def place_mark(pos, mark)
    raise "not empty place" if self[pos]=="-"
    raise "out of boudary" if pos.all?{|coord| coord.between?(0, 2)}
    @grids[pos] = mark      
  end

  def []=(pos, mark)
    x, y = pos[0], pos[1]
    @grids[x][y] = mark
  end

  def [](pos)
    x, y = pos
    @grids[x][y]
  end

  def render
    print "  0  1  2\n"
    @grids.each_with_index do |row, i|
      print i
      row.each do |grid|
        print  "|", grid, " "
      end
      print "\n"
    end
  end
  
  def cols
    cols = [[], [], []]
    @grids.each do |row|
      row.each_with_index do |grid, id|
        cols[id] << grid
      end
    end
    cols 
  end
  
  def diagonals
    up_dia = [[0, 0], [1, 1], [2, 2]]
    down_dia = [[2,0], [2,1], [2,2]]
    [up_dia, down_dia].map do |dir|
      dir.map do |x, y|
        @grids[x][y]
      end
    end
  end
  def dup
    dup_board = self.class.new
    @grids.each_with_index do |row, i|
      row.each_with_index do |elem, j|
        pos = [i, j]
        dup_board[pos] = @grids[i][j]
      end
    end
    dup_board
  end
end

class Game
  def initialize(board, p1, p2)
    @board = board 
    @p1, @p2 = p1, p2
    @p1.mark, @p2.mark = :o, :x
  end

  def play
    current_player = @p1
    @board.render
    until @board.won?
      current_player.move
      current_player = (current_player== @p1)? @p2 : @p1
      @board.render
    end
    winner = (current_player==@p1) ? @p2 : @p1
    print "winner is #{winner.name}!\n"
  end

end

class Player
  attr_accessor :name, :mark
  def initialize(name, board)
    @name = name
    @mark = :o
    @board = board
  end  
end
class HumanPlayer < Player
  def move
    puts "Input #{@name} choice "
    input = gets.chomp.split(" ").map{|x, y| Integer(x)}
    
    @board[input] = self.mark
  end

end

class ComputerPlayer < Player
  def initializ(name, board, mark)
    super(name, board, mark)
  end

  def move
    puts "#{name}'s turn"
    if win_move.nil?
      pos = random_move
    else
      pos = win_move
    end
    @board[pos] = self.mark
  end
  
  def win_move
    p self.mark
    win_move = []
    (0..2).each do |i|
      (0..2).each do |j|
        
        pos = [i, j]
        p pos
        next unless @board[pos] == "-"
        dup_board = @board.dup
        dup_board[pos] = self.mark
        win_move << pos  if dup_board.won? 
      end
    end
    p win_move
    win_move.sample
  end

  def random_move
    empty_positions = []
    (0..2).each do |i|
      (0..2).each do |j|
        pos = [i, j]
        empty_positions << pos if @board[pos] == "-"
      end
    end
    empty_positions.sample
  end
end
b = Board.new
p1 = HumanPlayer.new("asuka", b)
p2 = ComputerPlayer.new("computer", b)
g = Game.new(b, p1, p2)
g.play
