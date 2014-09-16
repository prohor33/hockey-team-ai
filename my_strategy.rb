require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './logic'
require './mover'

class MyStrategy
  
  STRIKE_ANGLE = 1.0 * Math::PI / 180.0
  
  @@logic_runned = false
 
  @@mover = Mover.new
 
  # @param [Hockeyist] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, move)
    # move.speed_up = -1.0
    # move.turn = Math::PI
    # move.action = ActionType::STRIKE
    
    if (!@@logic_runned)
      @@logic_runned = true
      Logic.instance.run_logic(world, game, move)
    end

    mover.move(me, world, game, move)
 
  end
end