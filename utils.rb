require "./logic"
require './model/unit'
require './model/hockeyist_type'

class Utils
  
  # @param [Float] x
  # @param [Float] y
  def self.find_the_nearest_hock(x, y)  # except goalie
    min = Logic.world.width * 10
    min_hock = nil
    for hock in Logic.world.hockeyists
      if (hock.type == HockeyistType::GOALIE)
        next
      end
      dist = hock.get_distance_to(x, y)
      if (dist < min)
        min = dist
        min_hock = hock
      end
    end
    min_hock
  end
  
  # @param [Unit] unit
  def self.find_the_nearest_hock_from_unit(unit)
    find_the_nearest_hock(unit.x, unit.y)
  end
  
  # @param [Player] player
  # @param [Unit] unit
  def self.find_the_nearest_player_hock_from_unit(player, unit)
    min = Logic.world.width
    min_hock = nil
    for hock in Logic.world.hockeyists
      if (hock.player_id != player.id)
        next
      end
      if (hock.type == HockeyistType::GOALIE)
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
  
  # @param [Move] target_move
  # @param [Move] src_move
  def self.clone_move(target_move, src_move)
    target_move.speed_up = src_move.speed_up
    target_move.turn = src_move.turn
    target_move.action = src_move.action
    target_move.pass_power = src_move.pass_power
    target_move.pass_angle = src_move.pass_angle
    target_move.teammate_index = src_move.teammate_index
  end
  
  # @param [Hockeyist] hock
  # @param [Unit] target
  # @param [ActionType] action
  def self.send_hock_to_unit(hock, target, action)
    Mover.moves[hock.id].turn = hock.get_angle_to_unit(target)
    Mover.moves[hock.id].action = action
    Mover.moves[hock.id].speed_up = 1.0
  end
  
  # @param [Hockeyist] hock
  # @param [Point] target_p
  # @param [ActionType] action
  def self.send_hock_to_p(hock, target_p, action)
    Mover.moves[hock.id].turn = get_hock_angle_to_p(hock, target_p)
    Mover.moves[hock.id].action = action
    Mover.moves[hock.id].speed_up = 1.0
  end
  
  # @param [Hockeyist] hock
  # @param [Float] delta_angle
  # @param [ActionType] action
  # @param [Float] speed_up
  def self.send_hock(hock, delta_angle, action, speed_up)
    Mover.moves[hock.id].turn = delta_angle
    Mover.moves[hock.id].action = action
    Mover.moves[hock.id].speed_up = speed_up
  end
  
  # @param [Hockeyist] hock
  def self.get_my_other_hock(not_this_hock)
    for hock in Logic.world.hockeyists
      if (!hock.teammate)
        next
      end
      if (hock.type == HockeyistType::GOALIE)
        next
      end
      if (hock.id != not_this_hock.id)
        return hock
      end
    end
    nil
  end
  
  # @param [Int] id
  def self.get_hock_by_id(id)
    for hock in Logic.world.hockeyists
      if (hock.id == id)
        return hock
      end
    end
    nil
  end
  
  # @param [Point] start_p
  # @param [Point] end_p
  # @param [Float] coef
  def self.get_point_between_two_points(start_p, end_p, coef)
    start_p + (end_p - start_p) * coef;
  end
  
  # @param [Point] start_p
  # @param [Point] end_p
  def self.get_middle_between_two_points(start_p, end_p)
    get_point_between_two_points(start_p, end_p, 0.5)
  end
  
  # @param [Hockeyist] hock
  # @param [Point] target_p
  def self.get_hock_angle_to_p(hock, target_p)
    hock.get_angle_to_unit(target_p.get_unit)
  end
  
  # @param [Hockeyist] hock
  # @param [Unit] unit
  # @return [False/True class]
  def self.is_unit_in_the_hock_area(hock, unit)
    is_unit_in_the_hock_area_spec(hock, unit, 120.0, Math::PI / 12.0)
  end
  
  # @param [Hockeyist] hock
  # @param [Unit] unit
  # @param [Float] area_size
  # @param [Float] area_angle
  # @return [False/True class]
  def self.is_unit_in_the_hock_area_spec(hock, unit, area_size, area_angle)
    dist = hock.get_distance_to_unit(unit)
    if (dist > area_size)
      return false
    end
    angle = hock.get_angle_to_unit(unit)
    if (angle > area_angle || angle < -area_angle)
      return false
    end
    return true
  end
  
  # @param [Player] player
  def self.get_player_net_p(player)
    p = Point.new(0, 0)
    p.x = (player.net_left + player.net_right) / 2.0
    p.y = (player.net_top + player.net_bottom) / 2.0
    p 
  end
  
  # @param [Player] player
  def self.get_player_net_size(player)
    p = Point.new(0, 0)
    p.x = Logic.game.goal_net_width
    p.y = Logic.game.goal_net_height
    p 
  end
  
  # @param [Hockeyist]
  def self.is_danger_area_clear(hock)
    danger_area_size = 140
    danger_area_angle = Math::PI / 10.0
    
    is_puck_in_danger = false
    for hock_i in Logic.world.hockeyists
      if (hock_i.player_id == Logic.me)
        next
      end
      if (hock_i.type == HockeyistType::GOALIE)
        next
      end
      if (Utils.is_unit_in_the_hock_area_spec(hock, hock_i, danger_area_size, danger_area_angle))
        is_puck_in_danger = true
        break
      end
    end
    !is_puck_in_danger
  end
end




