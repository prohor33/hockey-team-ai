require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'

class MyStrategy
  # @param [Hockeyist] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, move)
    # move.speed_up = -1.0
    # move.turn = Math::PI
    # move.action = ActionType::STRIKE

    opp_player = world.get_opponent_player
    # opp_player.neck.
    
    if (world.puck.owner_player_id == me.id)
      # puck is mine now!
      print "puck is mine now"
      #move.turn = opp_player.net.center
      move.turn = Math::PI
    else
      # need to get puck back
      move.speed_up = 1.0
      move.turn = me.get_angle_to_unit(world.puck)
      move.action = ActionType::TAKE_PUCK
    end
 
  end
end