#Need to create board visual

class Board
  attr_accessor :occupied_by
  attr_reader :spot

  # => Board objects are individual spaces.
  #    They are created in a standard order and added to an array
  #    so you can find them easily. Some code depends on this order.
  #    You can find them at the botton of this script
  # => Their default occupant is " " until the piece is created and
  #    updates the occupant to the piece's object
  # => I used a blank single-space string as default to accomodate
  #    for future board visualization
  def initialize(spot)
    @spot = spot
    @occupied_by = " "
    Game.add_to_board(self)
  end

  # => Updates the object with its new occupant- called from the piece's
  #    change_spot method
  # => Also called by space that was just departed from with no
  #    argument as to update the space with " " (blank)
  def update_occupied_by(piece=nil)
    piece == nil ? @occupied_by = " " : @occupied_by = piece
  end

  # => Easy access to a spot's occupant
  def occupied_by
    @occupied_by
  end
end

class Game

  # => Game has no instances except itself. All methods are
  #    class methods, this may change when I implement save/load games
  # => Init starts fresh arrays of board spots, pieces, and taken pieces
  def initialize
    @@board = []
    @@pieces = []
    @@taken = []
  end

  # => Called in spot init to add to board spots array
  def self.add_to_board(spot)
    @@board << spot
  end

  # => Called in piece init to add to pieces array
  def self.add_to_pieces(piece)
    @@pieces << piece
  end

  # => Called by the Game when a piece is taken-or basically
  #    overlapped and no spot contains it as an occupant anymore
  def self.add_to_taken(piece)
    @@taken << piece
  end

  # => Easy way to call or iterate through all the spots
  #    This is used in several methods below
  def self.board
    @@board
  end

  # => Easy way to call or iterate through pieces- Used later for
  #    updating potentials for all pieces
  def self.pieces
    @@pieces
  end

  # => Easy access to taken pieces. No use yet but will probably use
  #    this to display the taken pieces in the GUI
  def self.taken
    @@taken
  end

  # => Updates all piece's potential moves in one swift kic....
  #    Will only use when a King is selected to avoid allowing
  #    moves that will put it in check
  # => Need to test and make sure it wont break for taken pieces, or
  #    remove taken pieces from being updated at all
  def self.update_all_potentials
    @@pieces.each { |x| x.update_potential }
  end

  # => This method is used to see who occupies a spot. It is called
  #    by each piece when determining potential moves.
  # => This part will eventually be reworked as it iterates until it
  #    find the spot you chose, instead of just directly choosing
  #    the spot you are trying to see
  def self.whos_here(spot,i_am=nil)
    @@board.each { |x| i_am = x.occupied_by if x.spot == spot }
    i_am == " " ? i_am : i_am.color
  end

  # => This method has you choose a spot by its axis points in order to
  #    select the piece you want to move- it is called by make_move
  # => It is reliant on the order of spots initialized as mentioned above
  # => It will not let you choose a spot if there is no piece there or
  #    if that piece has no moves.
  def self.select_piece
    puts "Choose a piece by spot"
    input = gets.chomp
    select = input.split(",")
    spot = (((select[0].to_i-1)*8)+select[1].to_i)-1
    if @@board[spot].occupied_by == " "
      puts "There is no piece here, try again!"
      Game.select_piece
    else
      if @@board[spot].occupied_by.is_a?(King)
        Game.update_all_potentials
      end
      @@board[spot].update_potential
      if @@board[spot].occupied_by.potential.empty?
        puts "That piece has no available moves, pick another"
        Game.select_piece
      else
        @@board[spot]
      end
    end
  end

  # => This method selects the destination of the previously selected
  #    piece.  It checks the potential moves of that piece first and
  #    will not allow you to make an invalid move. -Called by make_move
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

  # => This method calls select_piece and select_destination. It also
  #    updates the pieces spot and the spots occupant and adds pieces
  #    that were taken to the @@taken array
  # => It currently updates all potentials but this will be changed.
  def self.make_move
    origin = Game.select_piece
    origin_piece = origin.occupied_by
    destination = Game.select_destination(origin_piece)
    Game.add_to_taken(destination.occupied_by) if destination.occupied_by != " "
    origin_piece.change_spot(destination)
    origin.update_occupied_by
    Game.update_all_potentials
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
