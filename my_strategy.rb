require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './logic'
# require './mover'

class MyStrategy
  
  @@logic_runned = false
 
  # @param [Hockeyist] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, move) 
    first_hock = false
    if (!@@logic_runned)
      @@logic_runned = true
      first_hock = true
      Logic.run_logic(world, game)
    end

    # just testing 
    # if (first_hock)
      hock_move = Mover.get_move_for_hock(me)    
      Utils.clone_move(move, hock_move)
    # end

    if (!first_hock)
      end_logic
      # puts "not smart"
    else
      # puts "smart"
    end
  end
  
  def end_logic
    @@logic_runned = false
  end
end