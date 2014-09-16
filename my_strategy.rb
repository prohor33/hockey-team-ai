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

    # move.speed_up = Mover.get_move_for_hock(me).speed_up

    hock_move = Mover.get_move_for_hock(me)
    # moving_data = hock_move.clone
    
    # wtf? how to clone in ruby?? :)
    moving_data.speed_up = hock_move.speed_up
    moving_data.action = hock_move.action
    moving_data.turn = hock_move.turn

    if (!smart_hock)
      end_logic
    end
  end
  
  def end_logic
    @@logic_runned = false
  end
end