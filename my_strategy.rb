require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './logic'
require './mover'

class MyStrategy
  
  @@logic_runned = false
 
  # @param [Hockeyist] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, moving_data)
    
    smart_hock = false
    if (!@@logic_runned)
      @@logic_runned = true
      smart_hock = true
      Logic.instance.run_logic(world, game)
    end

    hock_move = Mover.get_move_for_hock(me)    
    Utils.clone_move(moving_data, hock_move)

    if (!smart_hock)
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