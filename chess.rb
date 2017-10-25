#implement icons properly
#update pawn classes to white and black
#update_potential to only update when necessary
#add queen, king


class Knight
  attr_accessor :spot, :potential
  attr_reader :icon, :color, :opposite
  def initialize(spot,color="white")
    #color == "white" ? @icon = "\u2658" : @icon = "\u265E"
    color == "white" ? @color = "white" : @color = "black"
    color == "white" ? @opposite = "black" : @opposite = "white"
    @spot = spot
    @potential = []
    update_potential
    @spot.update_occupied_by(self)
    Game.add_to_pieces(self)
  end

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

  def change_spot(spot)
    spot.update_occupied_by(self)
    @spot = spot
    update_potential
  end
end

class Pawn < Knight

  def update_potential
    x = @spot.spot[0]
    y = @spot.spot[1]
    potential = []
    unless y == 8
      potential << [x,y+1] if Game.whos_here([x,y+1]) == " "
      potential << [x-1,y+1] if x != 1 && Game.whos_here([x-1,y+1]) == self.opposite
      potential << [x+1,y+1] if x != 8 && Game.whos_here([x+1,y+1]) == self.opposite
    end
    potential.each do |a|
      a.reject! { a.any? { |b| b < 1 || b > 8 } }
    end
    potential.delete([])
    @potential = potential
  end
end

class Rook < Knight

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
