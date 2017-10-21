class Knight
 attr_accessor :spot, :potential
 attr_reader :icon
 def initialize(spot)
   @icon = "\u2658"
   @spot = spot
   @potential = []
   update_potential
 end

 def update_potential
   x = @spot[0]
   y = @spot[1]
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
     a.reject! { a.any? { |b| b < 1 || b > 8 }}
   end
   potential.delete([])
   @potential = potential
 end

 def change_spot(spot)
   @spot = spot
   update_potential
 end
end
