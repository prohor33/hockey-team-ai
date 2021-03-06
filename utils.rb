require "./logic"
require './model/unit'
require './model/hockeyist_type'
require './game_const'
require './axis'

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
    send_hock_to_p_with_speed_up(hock, target_p, action, 1.0)
  end
  
  # @param [Hockeyist] hock
  # @param [Point] target_p
  # @param [ActionType] action
  def self.send_hock_to_p_with_slow_down(hock, target_p, action)
    dist = hock.get_distance_to(target_p.x, target_p.y)
    speed = Point.new(hock.speed_x, hock.speed_y).length
    max_speed_up_factor = Logic.game.hockeyist_speed_up_factor
    max_speed = Math.sqrt(2.0 * max_speed_up_factor * dist)
    speed_up = speed < max_speed ? 1.0 : -1.0
    
    in_dir_p = get_p_in_direction_from_unit(hock, 0.0, 10.0)
    if (in_dir_p.x * hock.speed_x < 0)
      # moving back
      speed_up = 1.0
    end
    send_hock_to_p_with_speed_up(hock, target_p, action, speed_up)
  end
  
  # @param [Hockeyist] hock
  # @param [Point] target_p
  # @param [ActionType] action
  # @param [Float] speed_up
  def self.send_hock_to_p_with_speed_up(hock, target_p, action, speed_up)
    Mover.moves[hock.id].turn = get_hock_angle_to_p(hock, target_p)
    Mover.moves[hock.id].action = action
    Mover.moves[hock.id].speed_up = speed_up
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
  # @param [Float] pass_angle
  # @param [Float] pass_power
  def self.send_hock_to_pass(hock, pass_angle, pass_power)
    Mover.moves[hock.id].turn = 0.0
    Mover.moves[hock.id].action = ActionType::PASS
    Mover.moves[hock.id].speed_up = 0.0
    Mover.moves[hock.id].pass_angle = pass_angle
    Mover.moves[hock.id].pass_power = pass_power
  end
  
  # @param [Hockeyist] hock
  # @param [Point] target_p
  # @param [Float] pass_power
  def self.send_hock_to_pass_to_p(hock, target_p, pass_power)
    send_hock_to_pass(hock, hock.get_angle_to(target_p.x, target_p.y), pass_power)
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
    # relative
    hock.get_angle_to_unit(target_p.get_unit)
  end
  
  # @param [Hockeyist] hock
  # @param [Unit] unit
  # @return [False/True class]
  def self.is_unit_in_the_hock_area(hock, unit)
    is_unit_in_the_hock_area_spec(hock, unit, GameConst::AREA_SIZE, GameConst::AREA_ANGLE)
  end
  
  # @param [Hockeyist] hock
  # @param [Unit] unit
  # @param [Float] area_size
  # @param [Float] area_angle
  # @return [False/True class]
  def self.is_unit_in_the_hock_area_spec(hock, unit, area_size, area_angle)
    is_unit_in_the_hock_area_spec_rot_angle(hock, unit, area_size, area_angle, 0)
  end
  
  # @param [Hockeyist] hock
  # @param [Unit] unit
  # @param [Float] area_size
  # @param [Float] area_angle
  # @param [Float] rot_angle <- relative
  # @return [False/True class]
  def self.is_unit_in_the_hock_area_spec_rot_angle(hock, unit, area_size, area_angle, rot_angle)
    dist = hock.get_distance_to_unit(unit)
    if (dist > area_size)
      return false
    end
    angle = hock.get_angle_to_unit(unit)  # relative angle
    angle += hock.angle # make t absolute
    angle = normalize_to_minus_p_plus_p(angle)
    rot_angle += hock.angle # make t absolute too
    if (angle > (rot_angle + area_angle) || angle < (rot_angle - area_angle))
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
    is_danger_area_clear_rot_angle(hock, 0)
  end
  
  # @param [Hockeyist]
  # @param [Float] rot_angle <- relative
  def self.is_danger_area_clear_rot_angle(hock, rot_angle)
    danger_area_size = GameConst::AREA_SIZE + 20
    danger_area_angle = GameConst::AREA_ANGLE + Math::PI / 20.0
    
    is_puck_in_danger = false
    for hock_i in Logic.world.hockeyists
      if (hock_i.player_id == Logic.me.id)
        next
      end
      if (hock_i.type == HockeyistType::GOALIE)
        next
      end
      if (Utils.is_unit_in_the_hock_area_spec_rot_angle(hock, hock_i, danger_area_size, danger_area_angle, rot_angle))
        is_puck_in_danger = true
        break
      end
    end
    !is_puck_in_danger
  end
  
  # @param [Hockeyist]
  def self.can_kick_someone(hock)
    danger_area_size = GameConst::AREA_SIZE
    danger_area_angle = GameConst::AREA_ANGLE
    
    can_kick = false
    for hock_i in Logic.world.hockeyists
      if (hock_i.player_id == Logic.me.id)
        next
      end
      if (hock_i.type == HockeyistType::GOALIE)
        next
      end
      if (Utils.is_unit_in_the_hock_area_spec(hock, hock_i, danger_area_size, danger_area_angle))
        can_kick = true
        break
      end
    end
    can_kick
  end
  
    # @param [Hockeyist] hock
  def self.get_target_p_in_net(hock)
    rink_centre = (Logic.game.rink_bottom + Logic.game.rink_top) / 2.0
    target_down = hock.y > rink_centre
    net_p = Utils.get_player_net_p(Logic.world.get_opponent_player)
    net_size = Utils.get_player_net_size(Logic.world.get_opponent_player)
    delta_y = net_size.y / 2.0 * 0.95
    attack_p = net_p
    attack_p.y += !target_down ? delta_y : -delta_y
    attack_p.x += net_size.x / 2.0
    attack_p
  end
  
  # @param [Hockeyist] hock
  def self.cancel_strike(hock)
    if (hock.last_action == ActionType::SWING)
      puts 'warning: cancel the strike'
      Utils.send_hock(hock, 0, ActionType::CANCEL_STRIKE, 0)
      return true
    end
    false
  end
  
  # @param [Hockeyist] hock
  def self.is_angle_to_strike(hock, target_p)
    min_delta_angle = Math::PI / 180.0
    get_hock_angle_to_p(hock, target_p).abs <= min_delta_angle
  end
  
  # @param [Hockeyist] hock
  # @param [Float] acc_angle
  def self.is_angle_to_strike_with_accuracy(hock, target_p, acc_angle)
    min_delta_angle = acc_angle
    get_hock_angle_to_p(hock, target_p).abs <= min_delta_angle
  end
  
  # @param [Hockeyist] hock
  def self.is_angle_to_pass(hock, target_p)
    min_delta_angle = Math::PI / 3.0
    get_hock_angle_to_p(hock, target_p).abs <= min_delta_angle
  end
  
  # @param [Hockeyist] attacker
  # @param [Hockeyist] another
  def self.can_hock_kick_another_one(attacker, another)
    angle = attacker.get_angle_to_unit(another) # relative angle
    dist = attacker.get_distance_to_unit(another)
    if (angle.abs > GameConst::AREA_ANGLE)
      return false
    end
    if (dist > GameConst::AREA_SIZE)
      return false
    end
    return true
  end
  
  # @param [Unit] unit
  # @param [Float] angle_dir
  # @param [Float] dist
  def self.get_p_in_direction_from_unit(unit, angle_dir, dist)
    angle = unit.angle + angle_dir
    angle = normalize_to_minus_p_plus_p(angle)
    p_dir = Point.new(((angle < -Math::PI / 2.0) || (angle > Math::PI / 2.0)) ? -1.0 : 1.0, Math.tan(angle))
    p_dir.normalize
    p_dir *= dist
    Point.new(unit.x, unit.y) + p_dir
  end
  
  # @param [Point] p
  def self.is_p_out_of_rink(p)
    if (p.x < Logic.game.rink_left || p.x > Logic.game.rink_right)
      return true
    end
    if (p.y > Logic.game.rink_bottom || p.y < Logic.game.rink_top)
      return true
    end
    return false
  end
  
  # @param [Point] p
  # @param [Axis] axis
  # @param [True/False] is_more
  def self.mirror_point(p, axis, is_more)
    case axis
    when Axis::X
      edge_x = is_more ? Logic.game.rink_right : Logic.game.rink_left
      dist_to_ege = (p.x - edge_x).abs
      new_x = is_more ? edge_x + dist_to_ege : edge_x - dist_to_ege
      return Point.new(new_x, p.y)
    when Axis::Y
      edge_y = is_more ? Logic.game.rink_bottom : Logic.game.rink_top
      dist_to_ege = (p.y - edge_y).abs
      new_y = is_more ? edge_y + dist_to_ege : edge_y - dist_to_ege
      return Point.new(p.x, new_y)
    else
      puts 'error axis'
    end
  end
  
  def self.get_rink_size
    Point.new(Logic.game.rink_right - Logic.game.rink_left, Logic.game.rink_bottom - Logic.game.rink_top)
  end
  
  def self.is_playing_without_goalies
    # puts 'to overtime left: ' + Logic.world.tick.to_s + ' of ' + Logic.game.tick_count.to_s
    Logic.world.tick > Logic.game.tick_count && Logic.me.goal_count == 0
  end
  
    # @param [Float] angle
  def self.normalize_to_minus_p_plus_p(angle)
    while (angle < -Math::PI)
      angle += 2.0 * Math::PI
    end
    while (angle > Math::PI)
      angle -= 2.0 * Math::PI
    end
    angle
  end
  
end




