require 'colorize'
class String
  def bg_gray
    "\e[47m#{self}\e[0m"
  end
end

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

  def display
    if @occupied_by == " "
      @occupied_by
    else
      @occupied_by.icon
    end
  end
end

class Game

  # => Game has no instances except itself. All methods are
  #    class methods, this may change when I implement save/load games
  # => Init starts fresh arrays of board spots, pieces, and taken pieces
  def initialize
    @@board = []
    @@pieces = []
    @@kings = []
    @@taken = []
    $danger_piece = nil
    $game_over = false
  end

  # => Called in spot init to add to board spots array
  def self.add_to_board(spot)
    @@board << spot
  end

  # => Called in piece init to add to pieces array
  def self.add_to_pieces(piece)
    @@pieces << piece
    @@kings << piece if piece.is_a?(King)
  end

  # => Called by the Game when a piece is taken-or basically
  #    overlapped and no spot contains it as an occupant anymore
  def self.add_to_taken(piece)
    $game_over = true if piece.is_a?(King)
    @@taken << piece
    Game.pieces.delete(piece)
    @@taken.sort_by! { |x| x.color }
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

  def self.kings
    @@kings
  end

  def self.display_check
    @@kings.each { |king| puts "#{king.color.capitalize} is in check!" if king.check == true }
  end

  # => Easy access to taken pieces. No use yet but will probably use
  #    this to display the taken pieces in the GUI
  def self.taken
    @@taken
  end

  def self.print_taken
    print "Taken pieces: "
    @@taken.each { |x| print x.icon }
    puts ""
  end

  # => Updates all piece's potential moves in one swift kic....
  #    Will only use when a King is selected to avoid allowing
  #    moves that will put it in check
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

  def self.check_self_check(color,allow=true)
    Game.kings.each do |king|
      if king.color == color
        Game.board.each do |board|
          if Game.whos_here(board.spot) != color && Game.whos_here(board.spot) != " "
            board.occupied_by.potential.each do |pot|
              if pot == king.spot.spot
                allow = false
              end
            end
          end
        end
      end
    end
    allow
  end

  def self.check_check
    Game.update_all_potentials
    Game.kings.each do |king|
      king.check = false
      Game.pieces.each do |piece|
        if piece.color == king.opposite
          piece.potential.each do |pot|
            if pot == king.spot.spot
              $danger_piece = piece
              king.check = true
              $game_over true if Game.check_mate(king)
            end
          end
        end
      end
    end
  end

  def self.check_mate(king,mate=true)
    if king.potential.empty?
      @@pieces.each do |piece|
        if piece.color == king.color
          piece.potential.any? do |spot|
            $danger_piece.potential.any? do |block|
              mate = false if spot == block
            end
          end
        end
        if mate == true
          piece.potential.any? do |spot|
            mate = false if spot == $danger_piece.spot.spot
          end
        end
      end
    else
      mate = false
    end
    mate
  end

  # => This method has you choose a spot by its axis points in order to
  #    select the piece you want to move- it is called by make_move
  # => It is reliant on the order of spots initialized as mentioned above
  # => It will not let you choose a spot if there is no piece there or
  #    if that piece has no moves.
  def self.select_piece(color)
    puts "#{color.capitalize}'s turn!"
    puts "Choose a piece by spot"
    input = gets.chomp
    select = input.split(",")
    spot = (((select[0].to_i-1)*8)+select[1].to_i)-1
    if @@board[spot].occupied_by == " " || @@board[spot].occupied_by.color != color
      puts "You don't have a piece here, try again!"
      Game.select_piece(color)
    else
      Game.update_all_potentials
      if @@board[spot].occupied_by.potential.empty?
        puts "That piece has no available moves, pick another"
        Game.select_piece(color)
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
  def self.make_move(color)
    origin = Game.select_piece(color)
    origin_piece = origin.occupied_by
    destination = Game.select_destination(origin_piece)
    destination_piece = destination.occupied_by unless destination.occupied_by == " "
    origin.update_occupied_by
    destination.update_occupied_by(origin_piece)
    Game.update_all_potentials
    if Game.check_self_check(origin_piece.color) == false
      origin.update_occupied_by(origin_piece)
      destination_piece == nil ? destination.update_occupied_by : destination.update_occupied_by(destination_piece)
      puts "That move leaves your King revealed, make another move"
      Game.make_move(color)
    else
      Game.add_to_taken(destination_piece) if destination_piece != nil
      origin_piece.change_spot(destination)
      Game.check_check
    end
  end

  def self.w_board
    puts "Y  _______________________________________________"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "8 |"+"  #{Game.board[7].display}  "+"|"+"  #{Game.board[15].display}  ".bg_gray+"|"+"  #{Game.board[23].display}  "+"|"+"  #{Game.board[31].display}  ".bg_gray+"|"+"  #{Game.board[39].display}  "+"|"+"  #{Game.board[47].display}  ".bg_gray+"|"+"  #{Game.board[55].display}  "+"|"+"  #{Game.board[63].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "7 |"+"  #{Game.board[6].display}  ".bg_gray+"|"+"  #{Game.board[14].display}  "+"|"+"  #{Game.board[22].display}  ".bg_gray+"|"+"  #{Game.board[30].display}  "+"|"+"  #{Game.board[38].display}  ".bg_gray+"|"+"  #{Game.board[46].display}  "+"|"+"  #{Game.board[54].display}  ".bg_gray+"|"+"  #{Game.board[62].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "6 |"+"  #{Game.board[5].display}  "+"|"+"  #{Game.board[13].display}  ".bg_gray+"|"+"  #{Game.board[21].display}  "+"|"+"  #{Game.board[29].display}  ".bg_gray+"|"+"  #{Game.board[37].display}  "+"|"+"  #{Game.board[45].display}  ".bg_gray+"|"+"  #{Game.board[53].display}  "+"|"+"  #{Game.board[61].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "5 |"+"  #{Game.board[4].display}  ".bg_gray+"|"+"  #{Game.board[12].display}  "+"|"+"  #{Game.board[20].display}  ".bg_gray+"|"+"  #{Game.board[28].display}  "+"|"+"  #{Game.board[36].display}  ".bg_gray+"|"+"  #{Game.board[44].display}  "+"|"+"  #{Game.board[52].display}  ".bg_gray+"|"+"  #{Game.board[60].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "4 |"+"  #{Game.board[3].display}  "+"|"+"  #{Game.board[11].display}  ".bg_gray+"|"+"  #{Game.board[19].display}  "+"|"+"  #{Game.board[27].display}  ".bg_gray+"|"+"  #{Game.board[35].display}  "+"|"+"  #{Game.board[43].display}  ".bg_gray+"|"+"  #{Game.board[51].display}  "+"|"+"  #{Game.board[59].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "3 |"+"  #{Game.board[2].display}  ".bg_gray+"|"+"  #{Game.board[10].display}  "+"|"+"  #{Game.board[18].display}  ".bg_gray+"|"+"  #{Game.board[26].display}  "+"|"+"  #{Game.board[34].display}  ".bg_gray+"|"+"  #{Game.board[42].display}  "+"|"+"  #{Game.board[50].display}  ".bg_gray+"|"+"  #{Game.board[58].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "2 |"+"  #{Game.board[1].display}  "+"|"+"  #{Game.board[9].display}  ".bg_gray+"|"+"  #{Game.board[17].display}  "+"|"+"  #{Game.board[25].display}  ".bg_gray+"|"+"  #{Game.board[33].display}  "+"|"+"  #{Game.board[41].display}  ".bg_gray+"|"+"  #{Game.board[49].display}  "+"|"+"  #{Game.board[57].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "1 |"+"  #{Game.board[0].display}  ".bg_gray+"|"+"  #{Game.board[8].display}  "+"|"+"  #{Game.board[16].display}  ".bg_gray+"|"+"  #{Game.board[24].display}  "+"|"+"  #{Game.board[32].display}  ".bg_gray+"|"+"  #{Game.board[40].display}  "+"|"+"  #{Game.board[48].display}  ".bg_gray+"|"+"  #{Game.board[56].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "     1     2     3     4     5     6     7     8   X"
    Game.print_taken
    Game.display_check
  end

  def self.b_board
    puts "Y  _______________________________________________"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "1 |"+"  #{Game.board[56].display}  "+"|"+"  #{Game.board[48].display}  ".bg_gray+"|"+"  #{Game.board[40].display}  "+"|"+"  #{Game.board[32].display}  ".bg_gray+"|"+"  #{Game.board[24].display}  "+"|"+"  #{Game.board[16].display}  ".bg_gray+"|"+"  #{Game.board[8].display}  "+"|"+"  #{Game.board[0].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "2 |"+"  #{Game.board[57].display}  ".bg_gray+"|"+"  #{Game.board[49].display}  "+"|"+"  #{Game.board[41].display}  ".bg_gray+"|"+"  #{Game.board[33].display}  "+"|"+"  #{Game.board[25].display}  ".bg_gray+"|"+"  #{Game.board[17].display}  "+"|"+"  #{Game.board[9].display}  ".bg_gray+"|"+"  #{Game.board[1].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "3 |"+"  #{Game.board[58].display}  "+"|"+"  #{Game.board[50].display}  ".bg_gray+"|"+"  #{Game.board[42].display}  "+"|"+"  #{Game.board[34].display}  ".bg_gray+"|"+"  #{Game.board[26].display}  "+"|"+"  #{Game.board[18].display}  ".bg_gray+"|"+"  #{Game.board[10].display}  "+"|"+"  #{Game.board[2].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "4 |"+"  #{Game.board[59].display}  ".bg_gray+"|"+"  #{Game.board[51].display}  "+"|"+"  #{Game.board[43].display}  ".bg_gray+"|"+"  #{Game.board[35].display}  "+"|"+"  #{Game.board[27].display}  ".bg_gray+"|"+"  #{Game.board[19].display}  "+"|"+"  #{Game.board[11].display}  ".bg_gray+"|"+"  #{Game.board[3].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "5 |"+"  #{Game.board[60].display}  "+"|"+"  #{Game.board[52].display}  ".bg_gray+"|"+"  #{Game.board[44].display}  "+"|"+"  #{Game.board[36].display}  ".bg_gray+"|"+"  #{Game.board[28].display}  "+"|"+"  #{Game.board[20].display}  ".bg_gray+"|"+"  #{Game.board[12].display}  "+"|"+"  #{Game.board[4].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "6 |"+"  #{Game.board[61].display}  ".bg_gray+"|"+"  #{Game.board[53].display}  "+"|"+"  #{Game.board[45].display}  ".bg_gray+"|"+"  #{Game.board[37].display}  "+"|"+"  #{Game.board[29].display}  ".bg_gray+"|"+"  #{Game.board[21].display}  "+"|"+"  #{Game.board[13].display}  ".bg_gray+"|"+"  #{Game.board[5].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "  |"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"
    puts "7 |"+"  #{Game.board[62].display}  "+"|"+"  #{Game.board[54].display}  ".bg_gray+"|"+"  #{Game.board[46].display}  "+"|"+"  #{Game.board[38].display}  ".bg_gray+"|"+"  #{Game.board[30].display}  "+"|"+"  #{Game.board[22].display}  ".bg_gray+"|"+"  #{Game.board[14].display}  "+"|"+"  #{Game.board[6].display}  ".bg_gray+"|"
    puts "  |"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"
    puts "  |"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"+"     ".bg_gray+"|"+"     "+"|"
    puts "8 |"+"  #{Game.board[63].display}  ".bg_gray+"|"+"  #{Game.board[55].display}  "+"|"+"  #{Game.board[47].display}  ".bg_gray+"|"+"  #{Game.board[39].display}  "+"|"+"  #{Game.board[31].display}  ".bg_gray+"|"+"  #{Game.board[23].display}  "+"|"+"  #{Game.board[15].display}  ".bg_gray+"|"+"  #{Game.board[7].display}  "+"|"
    puts "  |"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"+"_____".bg_gray+"|"+"_____"+"|"
    puts "     8     7     6     5     4     3     2     1   X"
    Game.print_taken
    Game.display_check
  end

  def self.play_game
    until $game_over == true
      puts "\e[H\e[2J"
      Game.w_board
      Game.make_move("white")
      puts "\e[H\e[2J"
      Game.b_board
      Game.make_move("black")
    end
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
b_king = King.new(s4_8,"black")
b_queen = Queen.new(s5_8,"black")
b_bishop = Bishop.new(s3_8,"black")
b_bishop = Bishop.new(s6_8,"black")
b_knight = Knight.new(s2_8,"black")
b_knight = Knight.new(s7_8,"black")
b_rook = Rook.new(s1_8,"black")
b_rook = Rook.new(s8_8,"black")
b_pawn = DownPawn.new(s1_7,"black")
b_pawn = DownPawn.new(s2_7,"black")
b_pawn = DownPawn.new(s3_7,"black")
b_pawn = DownPawn.new(s4_7,"black")
b_pawn = DownPawn.new(s5_7,"black")
b_pawn = DownPawn.new(s6_7,"black")
b_pawn = DownPawn.new(s7_7,"black")
b_pawn = DownPawn.new(s8_7,"black")
w_king = King.new(s4_1)
w_queen = Queen.new(s5_1)
w_bishop = Bishop.new(s3_1)
w_bishop = Bishop.new(s6_1)
w_knight = Knight.new(s2_1)
w_knight = Knight.new(s7_1)
w_rook = Rook.new(s1_1)
w_rook = Rook.new(s8_1)
w_pawn = UpPawn.new(s1_2)
w_pawn = UpPawn.new(s2_2)
w_pawn = UpPawn.new(s3_2)
w_pawn = UpPawn.new(s4_2)
w_pawn = UpPawn.new(s5_2)
w_pawn = UpPawn.new(s6_2)
w_pawn = UpPawn.new(s7_2)
w_pawn = UpPawn.new(s8_2)
