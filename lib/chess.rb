# => streamline order of operations for updating potential moves and general gameplay
# => add save/load

class Piece
  attr_accessor :spot, :potential, :team_in_path, :moved
  attr_reader :icon, :color, :opposite
  # => Pieces init by spot's object name, not the actual spot (e.g. s1_1)
  #   this links the piece to the object of the space it occupies so
  #   you can easily access any attribute of either side
  # => Also, each piece is added to an array for easy access to update
  #    all pieces potential moves
  def initialize(spot,color="white")
    color == "white" ? @color = "white" : @color = "black"
    color == "white" ? @opposite = "black" : @opposite = "white"
    @spot = spot
    @potential = []
    @team_in_path = []
    @moved = false
    @spot.update_occupied_by(self)
    Game.add_to_pieces(self)
    create_icon
  end

  def up_x_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[1] == y && king[0] > x
    end
    unless x == 8
      x += 1
      until x >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        x += 1
      end
    end
  end

  def down_x_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[1] == y && king[0] < x
    end
    unless x == 1
      x -= 1
      until x <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        x -= 1
      end
    end
  end

  def up_y_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[0] == x && king[1] > y
    end
    unless y == 8
      y += 1
      until y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        y += 1
      end
    end
  end

  def down_y_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[0] == x && king[1] < y
    end
    unless y == 1
      y -= 1
      until y <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        y -= 1
      end
    end
  end

  def up_up_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[0] > x && king[1] > y
    end
    unless x == 8 || y == 8
      x += 1
      y += 1
      until x >= 9 || y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        x += 1
        y += 1
      end
    end
  end

  def down_up_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[0] < x && king[1] > y
    end
    unless x == 1 || y == 8
      x -= 1
      y += 1
      until x <= 0 || y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        x -= 1
        y += 1
      end
    end
  end

  def up_down_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[0] > x && king[1] < y
    end
    unless y == 1 || x == 8
      x += 1
      y -= 1
      until y <= 0 || x >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        x += 1
        y -= 1
      end
    end
  end

  def down_down_moves(king)
    x = @spot.spot[0]
    y = @spot.spot[1]
    done = false
    danger_path = false
    unless king == nil
      danger_path = true if king[0] < x && king[1] < y
    end
    unless y == 1 || x == 1
      y -= 1
      x -= 1
      until y <= 0 || x <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          @potential << [x,y]
          Game.danger_path << [x,y] if danger_path == true
        elsif Game.whos_here([x,y]) == @opposite
          @potential << [x,y]
          done = true
        else
          @team_in_path << [x,y]
          done = true
        end
        x -= 1
        y -= 1
      end
    end
  end

  # => This is called by the game, it takes an argument of the destination
  #    and updates the destination spot's object with itself as its occupant,
  #    as well as updates itself with the object it now occupies
  # => If the piece is taking an opponent, the oppenent's spot is not refreshed
  #    and therefore cannot be selected anymore since pieces are selected
  #    by the spot, and not the piece itself
  # => The taken piece is added to a @@taken array in the Game class
  # => Marks the piece as moved to disqualify it from special moves
  def change_spot(spot)
    spot.update_occupied_by(self)
    @spot = spot
    @moved = true
  end
end

class Knight < Piece

  def create_icon
    @color == "black" ? @icon = "\u2658" : @icon = "\u265E"
  end

  # => Adds all potential moves to an array,
  #    deletes the ones that are out of bounds,
  #    then deletes the ones that are occupied by a team member
  def update_potential(king=nil)
    x = @spot.spot[0]
    y = @spot.spot[1]
    team_in_path = []
    potential = [
                 [x+2,y+1],
                 [x+2,y-1],
                 [x-2,y+1],
                 [x-2,y-1],
                 [x+1,y+2],
                 [x+1,y-2],
                 [x-1,y+2],
                 [x-1,y-2]]
    potential.each do |a|
      a.reject! { a.any? { |b| b < 1 || b > 8 } }
    end
    potential.delete([])
    potential.each do |x|
      team_in_path << x.dup if Game.whos_here(x) == self.color
      x.reject! { Game.whos_here(x) == self.color }
    end
    potential.delete([])
    @potential = potential
    @team_in_path = team_in_path
  end
end

class UpPawn < Piece
  # => Adds forward space if its empty
  #    and forward diagonals if occupied by opponent and not out of bounds
  def update_potential(king=nil)
    x = @spot.spot[0]
    y = @spot.spot[1]
    team_in_path = []
    potential = []
    unless y == 8
      potential << [x,y+1] if Game.whos_here([x,y+1]) == " "
      potential << [x-1,y+1] if x != 1 && Game.whos_here([x-1,y+1]) == self.opposite
      potential << [x+1,y+1] if x != 8 && Game.whos_here([x+1,y+1]) == self.opposite
      team_in_path << [x-1,y+1] if x != 1 && Game.whos_here([x-1,y+1]) == self.color
      team_in_path << [x+1,y+1] if x != 8 && Game.whos_here([x+1,y+1]) == self.color
      unless @moved == true
        potential << [x,y+2] if Game.whos_here([x,y+1]) == " " && Game.whos_here([x,y+2]) == " "
      end
    end
    @potential = potential
    @team_in_path = team_in_path
  end

  def create_icon
    @color == "black" ? @icon = "\u2659" : @icon = "\u265F"
  end

  def change_spot(spot)
    spot.update_occupied_by(self)
    @spot = spot
    @moved = true
    if spot.spot[1] == 8
      polymorph
    end
  end

  def polymorph
    Queen.new(@spot,@color)
    Game.pieces.delete(self)
  end
end

class DownPawn < Piece

  # => Adds forward space if its empty
  #    and forward diagonals if occupied by opponent and not out of bounds
  def update_potential(king=nil)
    x = @spot.spot[0]
    y = @spot.spot[1]
    team_in_path = []
    potential = []
    unless y == 1
      potential << [x,y-1] if Game.whos_here([x,y-1]) == " "
      potential << [x-1,y-1] if x != 1 && Game.whos_here([x-1,y-1]) == self.opposite
      potential << [x+1,y-1] if x != 8 && Game.whos_here([x+1,y-1]) == self.opposite
      team_in_path << [x-1,y-1] if x != 1 && Game.whos_here([x-1,y-1]) == self.color
      team_in_path << [x+1,y-1] if x != 8 && Game.whos_here([x+1,y-1]) == self.color
      unless @moved == true
        potential << [x,y-2] if Game.whos_here([x,y-1]) == " " && Game.whos_here([x,y-2]) == " "
      end
    end
    @potential = potential
    @team_in_path = team_in_path
  end

  def create_icon
    @color == "black" ? @icon = "\u2659" : @icon = "\u265F"
  end

  def change_spot(spot)
    spot.update_occupied_by(self)
    @spot = spot
    @moved = true
    if spot.spot[1] == 1
      polymorph
    end
  end

  def polymorph
    Queen.new(@spot,@color)
    Game.pieces.delete(self)
  end
end

class Rook < Piece

  # => Checks spots in one direction and adds to potential moves until
  #    it reaches the end, a team member, or an opponent. If it reaches
  #    an oppenent it adds its space as the last move in this direction
  # => Does this 3 more times for the other directions
  # => Needs to be updated to allow castle move
  def update_potential(king=nil)
    @team_in_path = []
    @potential = []
    up_x_moves(king)
    down_x_moves(king)
    up_y_moves(king)
    down_y_moves(king)
  end

  def create_icon
    @color == "black" ? @icon = "\u2656" : @icon = "\u265C"
  end
end

class Bishop < Piece

  # => Checks spots in one direction and adds to potential moves until
  #    it reaches the end, a team member, or an opponent. If it reaches
  #    an oppenent it adds its space as the last move in this direction
  # => Does this 3 more times for the other directions
  def update_potential(king=nil)
    @team_in_path = []
    @potential = []
    up_up_moves(king)
    up_down_moves(king)
    down_up_moves(king)
    down_down_moves(king)
  end

  def create_icon
    @color == "black" ? @icon = "\u2657" : @icon = "\u265D"
  end
end

class Queen < Piece

  # => Checks spots in one direction and adds to potential moves until
  #    it reaches the end, a team member, or an opponent. If it reaches
  #    an oppenent it adds its space as the last move in this direction
  # => Does this 7 more times for the other directions
  def update_potential(king=nil)
    @team_in_path = []
    @potential = []
    up_x_moves(king)
    down_x_moves(king)
    up_y_moves(king)
    down_y_moves(king)
    up_up_moves(king)
    up_down_moves(king)
    down_up_moves(king)
    down_down_moves(king)
  end

  def create_icon
    @color == "black" ? @icon = "\u2655" : @icon = "\u265B"
  end
end

class King < Piece
  attr_accessor :check
  # => Adds all potential moves to an array,
  #    deletes the ones that are out of bounds,
  #    then deletes the ones that are occupied by a team member
  #    Now deletes moves that would put it in check even by taking a piece
  # => Needs to be updated to allow castle move
  def update_potential(spot=nil)
    x = @spot.spot[0]
    y = @spot.spot[1]
    team_in_path = []
    rooks = []
    potential = [
                 [x+1,y+1],
                 [x+1,y-1],
                 [x-1,y+1],
                 [x-1,y-1],
                 [x+1,y],
                 [x-1,y],
                 [x,y+1],
                 [x,y-1]]
    potential.each do |a|
      a.reject! { a.any? { |b| b < 1 || b > 8 } }
    end
    potential.delete([])
    potential.each do |x|
      team_in_path << x.dup if Game.whos_here(x) == self.color
      x.reject! { Game.whos_here(x) == self.color }
    end
    potential.delete([])
    # => below is castle move
    if @moved == false
      Game.pieces.each do |rook|
        if rook.is_a?(Rook) && rook.color == @color
          rooks << rook
          if rook.moved == false && rook.team_in_path.include?(self.spot.spot)
            potential << [x-2,y] if rook.spot.spot[0] < x
            potential << [x+2,y] if rook.spot.spot[0] > x
          end
        end
      end
    end
    # => above is castle move
    potential.each do |king|
      Game.pieces.each do |piece|
        if piece.color == @opposite
          piece.potential.each do |path|
            king.reject! { path == king }
          end
          piece.team_in_path.each do |check|
            king.reject! { check == king }
          end
        end
      end
    end
    potential.delete([])
    potential.delete([x+2,y]) unless potential.include?([x+1,y])
    potential.delete([x-2,y]) unless potential.include?([x-1,y])
    @potential = potential
    @team_in_path = team_in_path
    @rooks = rooks
  end

  def create_icon
    @color == "black" ? @icon = "\u2654" : @icon = "\u265A"
    @check = false
    @rooks = []
  end

  def change_spot(spot)
    x = spot.spot[0]
    y = spot.spot[1]
    if @spot.spot[0] - x == 2
      @rooks.each do |rook|
        if rook.spot.spot[0] < @spot.spot[0]
          rook.spot.update_occupied_by
          rook.change_spot(Game.board[(x*8)+y-1])
        end
      end
    elsif @spot.spot[0] - x == (-2)
      @rooks.each do |rook|
        if rook.spot.spot[0] > @spot.spot[0]
          rook.spot.update_occupied_by
          rook.change_spot(Game.board[((x-2)*8)+y-1])
        end
      end
    end
    spot.update_occupied_by(self)
    @spot = spot
    @moved = true
  end
end
