class Board
  attr_accessor :occupied_by
  def initialize(piece=nil)
    update_spot(piece)
  end

  def update_spot(piece=nil)
    piece == nil ? @occupied_by = " " : @occupied_by = piece
  end

  def check_spot
    @occupied_by
  end
end
