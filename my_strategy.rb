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
 
  # @param [Hockeyist] hock
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(hock, world, game, moving_data)
    
    first_hock = false
    if (!@@logic_runned)
      @@logic_runned = true
      first_hock = true
      Logic.instance.run_logic(world, game)
    end

    # just testing 
    # if (first_hock)
      hock_move = Mover.get_move_for_hock(hock)    
      Utils.clone_move(moving_data, hock_move)
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