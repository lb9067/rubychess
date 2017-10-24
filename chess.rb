class Knight
  attr_accessor :spot, :potential
  attr_reader :icon, :color, :opposite
  def initialize(spot,color="white")
    color == "white" ? @icon = "\u2658" : @icon = "\u265E"
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
    potential << [x,y+1] if Game.whos_here([x,y+1]) == " "
    potential << [x-1,y+1] if Game.whos_here([x-1,y+1]) == self.opposite
    potential << [x+1,y+1] if Game.whos_here([x+1,y+1]) == self.opposite
    potential.each do |a|
      a.reject! { a.any? { |b| b < 1 || b > 8 } }
    end
    potential.delete([])
    @potential = potential
  end
end
