class Mover
  # @param [Hockeyist] me
  # @param [World] world
  # @param [Game] game
  # @param [Move] move
  def move(me, world, game, move)

    opp_player = world.get_opponent_player
    my_player = world.get_my_player
    # opp_player.neck.

    if (world.puck.owner_player_id == my_player.id)
      # puck is mine now!
      # print "puck is mine now"
      #move.turn = opp_player.net.center
      move.turn = Math::PI

      net_x = 0.5 * (opp_player.net_back + opp_player.net_front)
      net_y = 0.5 * (opp_player.net_bottom + opp_player.net_top)

      angle_to_net = me.get_angle_to(net_x, net_y)
      move.turn = angle_to_net

      if (angle_to_net.abs < STRIKE_ANGLE)
        move.action = ActionType::STRIKE
      end
    else
    # need to get puck back
      move.speed_up = 1.0
      move.turn = me.get_angle_to_unit(world.puck)
      move.action = ActionType::TAKE_PUCK
    end
  end
end