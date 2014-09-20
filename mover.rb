require './logic'
require './model/move'

class Mover

  @@moves = Hash.new{nil}

  def self.moves
    @@moves
  end
  def self.moves=moves_tmp
    @@moves = move_tmp
  end

  def self.new_tick
    @@moves = Hash.new{nil}
    
    for hock in Logic.world.hockeyists
      @@moves[hock.id] = Move.new
    end
  end

  # @param [Hockeyist] hock
  def self.get_move_for_hock(hock)
    move_tmp = @@moves[hock.id]
    if (!move_tmp)
      puts 'error set moving'
    end
    
    move_tmp
  end
end