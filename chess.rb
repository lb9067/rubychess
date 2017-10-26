#implement icons
#create board (use colorize?)
#update_potential to only update when necessary
# e.g. when piece selected, update all when king selected
#remove potential king moves that puts it in check
#recognize check-mate
#add first move bonus to pawns
#add queen polymorph to pawns
#add castle move for rook/king
#update pawn classes to white and black


class Knight
  attr_accessor :spot, :potential
  attr_reader :icon, :color, :opposite
  # => Pieces init by spot's object name, not the actual spot (e.g. s1_1)
  #   this links the piece to the object of the space it occupies so
  #   you can easily access any attribute of either side
  # => Also, each piece is added to an array, havent needed that yet so
  #    I might delete it
  def initialize(spot,color="white")
    #color == "white" ? @icon = "\u2658" : @icon = "\u265E"
    color == "white" ? @color = "white" : @color = "black"
    color == "white" ? @opposite = "black" : @opposite = "white"
    @spot = spot
    @potential = []
    @spot.update_occupied_by(self)
    Game.add_to_pieces(self)
  end
  # => Adds all potential moves to an array,
  #    deletes the ones that are out of bounds,
  #    then deletes the ones that are occupied by a team member
  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
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
      x.reject! { Game.whos_here(x) == self.color }
    end
    potential.delete([])
    @potential = potential
  end
  # => This is called by the game, it takes an argument of the destination
  #    and updates the destination spot's object with itself as its occupant,
  #    as well as updates itself with the object it now occupies
  # => If the piece is taking an opponent, the oppenent's spot is not refreshed
  #    and therefore cannot be selected anymore since pieces are selected
  #    by the spot, and not the piece itself
  # => The taken piece is added to a @@taken array in the Game class
  # => This also currently updates its own potential moves but this will be
  #    deleted and called from somewhere else
  def change_spot(spot)
    spot.update_occupied_by(self)
    @spot = spot
    update_potential
  end
end

class Pawn < Knight
  # => Adds forward space if its empty
  #    and forward diagonals if occupied by opponent and not out of bounds
  # => Needs to be updated or duplicated with opposite team's moves
  # => Needs to be updated to allow first move bonus
  # => Needs to be updated with queen polymorph
  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
    potential = []
    unless y == 8
      potential << [x,y+1] if Game.whos_here([x,y+1]) == " "
      potential << [x-1,y+1] if x != 1 && Game.whos_here([x-1,y+1]) == self.opposite
      potential << [x+1,y+1] if x != 8 && Game.whos_here([x+1,y+1]) == self.opposite
    end
    @potential = potential
  end
end

class Rook < Knight
  # => Checks spots in one direction and adds to potential moves until
  #    it reaches the end, a team member, or an opponent. If it reaches
  #    an oppenent it adds its space as the last move in this direction
  # => Does this 3 more times for the other directions
  # => Needs to be updated to allow castle move
  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
    potential = []
    done = false
    unless x == 8
      x += 1
      until x >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x += 1
      end
    end
    done = false
    x = @spot.spot[0]
    unless x == 1
      x -= 1
      until x <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x -= 1
      end
    end
    done = false
    x = @spot.spot[0]
    unless y == 8
      y += 1
      until y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        y += 1
      end
    end
    done = false
    y = @spot.spot[1]
    unless y == 1
      y -= 1
      until y <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        y -= 1
      end
    end
    @potential = potential
  end
end

class Bishop < Knight
  # => Checks spots in one direction and adds to potential moves until
  #    it reaches the end, a team member, or an opponent. If it reaches
  #    an oppenent it adds its space as the last move in this direction
  # => Does this 3 more times for the other directions
  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
    potential = []
    done = false
    unless x == 8 || y == 8
      x += 1
      y += 1
      until x >= 9 || y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x += 1
        y += 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless x == 1 || y == 8
      x -= 1
      y += 1
      until x <= 0 || y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x -= 1
        y += 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless y == 1 || x == 8
      x += 1
      y -= 1
      until y >= 0 || x >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x += 1
        y -= 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless y == 1 || x == 1
      y -= 1
      until y <= 0 || x <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x -= 1
        y -= 1
      end
    end
    @potential = potential
  end
end

class Queen < Knight
  # => Checks spots in one direction and adds to potential moves until
  #    it reaches the end, a team member, or an opponent. If it reaches
  #    an oppenent it adds its space as the last move in this direction
  # => Does this 7 more times for the other directions
  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
    potential = []
    done = false
    unless x == 8
      x += 1
      until x >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x += 1
      end
    end
    done = false
    x = @spot.spot[0]
    unless x == 1
      x -= 1
      until x <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x -= 1
      end
    end
    done = false
    x = @spot.spot[0]
    unless y == 8
      y += 1
      until y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        y += 1
      end
    end
    done = false
    y = @spot.spot[1]
    unless y == 1
      y -= 1
      until y <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        y -= 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless x == 8 || y == 8
      x += 1
      y += 1
      until x >= 9 || y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x += 1
        y += 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless x == 1 || y == 8
      x -= 1
      y += 1
      until x <= 0 || y >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x -= 1
        y += 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless y == 1 || x == 8
      x += 1
      y -= 1
      until y >= 0 || x >= 9 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x += 1
        y -= 1
      end
    end
    done = false
    x = @spot.spot[0]
    y = @spot.spot[1]
    unless y == 1 || x == 1
      y -= 1
      until y <= 0 || x <= 0 || done == true
        if Game.whos_here([x,y]) == " "
          potential << [x,y]
        elsif Game.whos_here([x,y]) == @opposite
          potential << [x,y]
          done = true
        else
          done = true
        end
        x -= 1
        y -= 1
      end
    end
    @potential = potential
  end
end

class King < Knight
  # => Adds all potential moves to an array,
  #    deletes the ones that are out of bounds,
  #    then deletes the ones that are occupied by a team member
  # => Needs to be updated to reject moves that result in a check
  # => Needs to be updated to allow castle move
  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
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
      x.reject! { Game.whos_here(x) == self.color }
    end
    potential.delete([])
    @potential = potential
  end
end
