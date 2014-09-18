require "./logic"
require './model/unit'

class Utils
  
  # param [Float] x
  # param [Float] y
  def self.find_the_nearest_hock(x, y)
    min = Logic.world.width * 10
    min_hock = nil
    for hock in Logic.world.hockeyists
      dist = hock.get_distance_to(x, y)
      if (dist < min)
        min = dist
        min_hock = hock
      end
    end
    min_hock
  end
  
  # param [Unit] unit
  def self.find_the_nearest_hock_from_unit(unit)
    find_the_nearest_hock(unit.x, unit.y)
  end
  
  # param [Player] player
  # param [Unit] unit
  def self.find_the_nearest_player_hock_from_unit(player, unit)
    min = Logic.world.width
    min_hock = nil
    for hock in Logic.world.hockeyists
      if (hock.player_id != player.id)
        next
      end
      dist = hock.get_distance_to(unit.x, unit.y)
      if (dist < min)
        min = dist
        min_hock = hock
      end
    end
    min_hock
  end
  
  # param [Move] target_move
  # param [Move] src_move
  def self.clone_move(target_move, src_move)
    target_move.speed_up = src_move.speed_up
    target_move.turn = src_move.turn
    target_move.action = src_move.action
    target_move.pass_power = src_move.pass_power
    target_move.pass_angle = src_move.pass_angle
    target_move.teammate_index = src_move.teammate_index
  end
  
end