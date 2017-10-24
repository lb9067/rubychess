class Board
  attr_accessor :occupied_by
  attr_reader :spot
  def initialize(spot,piece=nil)
    @spot = spot
    update_occupied_by(piece)
    Game.add_to_board(self)
  end

  def update_occupied_by(piece=nil)
    piece == nil ? @occupied_by = " " : @occupied_by = piece
  end

  def occupied_by
    @occupied_by
  end
end

class Game
  def initialize
    @@board = []
    @@pieces = []
  end

  def self.add_to_board(spot)
    @@board << spot
  end

  def self.add_to_pieces(piece)
    @@pieces << piece
  end

  def self.board
    @@board
  end

  def self.pieces
    @@pieces
  end

  def self.update_all_potentials
    @@pieces.each { |x| x.update_potential }
  end

  def self.whos_here(spot,i_am=nil)
    @@board.each { |x| i_am = x.occupied_by if x.spot == spot }
    i_am == " " ? i_am : i_am.color
  end

  def self.select_piece
    puts "Choose a piece by spot"
    input = gets.chomp
    select = input.split(",")
    spot = (((select[0].to_i-1)*8)+select[1].to_i)-1
    if @@board[spot].occupied_by == " "
      puts "There is no piece here, try again!"
      Game.select_piece
    else
      @@board[spot]
    end
  end

  def self.select_destination(piece)
    puts "Choose a destination spot"
    input = gets.chomp
    select = input.split(",")
    spot = (((select[0].to_i-1)*8)+select[1].to_i)-1
    if piece.potential.include?(@@board[spot].spot)
      @@board[spot]
    else
      puts "You can't go there, try again"
      select_destination(piece)
    end
  end


  def self.make_move
    origin = Game.select_piece
    origin_piece = origin.occupied_by
    destination = Game.select_destination(origin_piece)
    origin_piece.change_spot(destination)
    origin.update_occupied_by
  end

end

Game.new
s1_1 = Board.new([1,1])
s1_2 = Board.new([1,2])
s1_3 = Board.new([1,3])
s1_4 = Board.new([1,4])
s1_5 = Board.new([1,5])
s1_6 = Board.new([1,6])
s1_7 = Board.new([1,7])
s1_8 = Board.new([1,8])
s2_1 = Board.new([2,1])
s2_2 = Board.new([2,2])
s2_3 = Board.new([2,3])
s2_4 = Board.new([2,4])
s2_5 = Board.new([2,5])
s2_6 = Board.new([2,6])
s2_7 = Board.new([2,7])
s2_8 = Board.new([2,8])
s3_1 = Board.new([3,1])
s3_2 = Board.new([3,2])
s3_3 = Board.new([3,3])
s3_4 = Board.new([3,4])
s3_5 = Board.new([3,5])
s3_6 = Board.new([3,6])
s3_7 = Board.new([3,7])
s3_8 = Board.new([3,8])
s4_1 = Board.new([4,1])
s4_2 = Board.new([4,2])
s4_3 = Board.new([4,3])
s4_4 = Board.new([4,4])
s4_5 = Board.new([4,5])
s4_6 = Board.new([4,6])
s4_7 = Board.new([4,7])
s4_8 = Board.new([4,8])
s5_1 = Board.new([5,1])
s5_2 = Board.new([5,2])
s5_3 = Board.new([5,3])
s5_4 = Board.new([5,4])
s5_5 = Board.new([5,5])
s5_6 = Board.new([5,6])
s5_7 = Board.new([5,7])
s5_8 = Board.new([5,8])
s6_1 = Board.new([6,1])
s6_2 = Board.new([6,2])
s6_3 = Board.new([6,3])
s6_4 = Board.new([6,4])
s6_5 = Board.new([6,5])
s6_6 = Board.new([6,6])
s6_7 = Board.new([6,7])
s6_8 = Board.new([6,8])
s7_1 = Board.new([7,1])
s7_2 = Board.new([7,2])
s7_3 = Board.new([7,3])
s7_4 = Board.new([7,4])
s7_5 = Board.new([7,5])
s7_6 = Board.new([7,6])
s7_7 = Board.new([7,7])
s7_8 = Board.new([7,8])
s8_1 = Board.new([8,1])
s8_2 = Board.new([8,2])
s8_3 = Board.new([8,3])
s8_4 = Board.new([8,4])
s8_5 = Board.new([8,5])
s8_6 = Board.new([8,6])
s8_7 = Board.new([8,7])
s8_8 = Board.new([8,8])
knight1 = Knight.new(s2_1)
#Game.select_spot
Game.make_move
