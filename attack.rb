require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './logic'
require './utils'
require './logic_state'
require './point'
require 'singleton'
require './smart_utils'
require './axis'

module AttackStrategy
  ATTACK = 0
  GET_RID_OF_PUCK = 1
end

class Attack
  include Singleton
  
  @puck_hock = nil
  @assist_hock = nil
  
  @strategy = -1
  
  def self.decide # Decide strategy
    puts 'decide'
    
    @puck_hock = Utils.find_the_nearest_player_hock_from_unit(Logic.world.get_my_player, Logic.puck)
    @assist_hock = Utils.get_my_other_hock(@puck_hock)
    
    # Observer situation
    is_danger = SmartUtils.can_smb_kick_hock(@puck_hock)
    
    # @strategy = AttackStrategy::GET_RID_OF_PUCK
    
    if (is_danger)
      # need to get rid of the puck
      @strategy = AttackStrategy::GET_RID_OF_PUCK
      puts 'decide to get rid of the puck'
    else
      # just go forward
      @strategy = AttackStrategy::ATTACK
      puts 'decide to attack'
    end
  end
  
  def self.iter
    case @strategy
    when AttackStrategy::ATTACK
      attack
    when AttackStrategy::GET_RID_OF_PUCK
      get_rid_of_puck
    else
      puts "error strategy"
    end
  end
  
  def self.attack
    # Update hockeyists
    @puck_hock = Utils.get_hock_by_id(@puck_hock.id)
    @assist_hock = Utils.get_hock_by_id(@assist_hock.id)

    net_target_p = Utils.get_target_p_in_net(@puck_hock)
    too_close_to_strike = SmartUtils.too_close_to_strike(@puck_hock)
    too_far_to_strike = SmartUtils.too_far_to_strike(@puck_hock)
    
    Utils.send_hock_to_p(@puck_hock, net_target_p, ActionType::NONE)
    
    if (Utils.is_angle_to_strike(@puck_hock, net_target_p))
      need_to_strike = false
      
      Utils.send_hock_to_p(@puck_hock, net_target_p, ActionType::SWING)
    
      if (Logic.game.tick_count > Logic.world.tick_count)
        # overtime
        need_to_strike = true
      end
      if (too_close_to_strike)
        need_to_strike = true
      end
      if (@puck_hock.last_action == ActionType::SWING)
        last_action_time_lef = Logic.game.tick_count - @puck_hock.last_action_tick
        if (@puck_hock.swing_ticks >= Logic.game.max_effective_swing_ticks)
          need_to_strike = true
        end
      end
      
      if (need_to_strike)
        Utils.send_hock_to_p(@puck_hock, net_target_p, ActionType::STRIKE)
      end
    end

    # other hock stays in the middle
    # net_p = Point.new(Logic.me.net_back, (Logic.me.net_top + Logic.me.net_bottom) / 2.0)
    net_p = Utils.get_player_net_p(Logic.me)
    defend_p = Utils.get_middle_between_two_points(Point.from_unit(Logic.puck), net_p)
    Utils.send_hock_to_p(@assist_hock, defend_p, ActionType::TAKE_PUCK)
  end
  
  def self.get_rid_of_puck
    # puts 'get rid of the puck'
    @puck_hock = Utils.get_hock_by_id(@puck_hock.id)
    @assist_hock = Utils.get_hock_by_id(@assist_hock.id)
    
    pass_p = find_place_to_pass
    
    if (!pass_to_p_accordingly_borders(pass_p))
      puts 'could not find save way to pass => just attack'
      @strategy = AttackStrategy::ATTACK
      attack
    end
    
    # angle_to_pass = Utils.get_hock_angle_to_p(@puck_hock, pass_p)
    # Utils.send_hock(@puck_hock, angle_to_pass, ActionType::NONE, 0.0)
#     
    # if (Utils.is_angle_to_pass(@puck_hock, pass_p))
      # puts 'pass'
      # Utils.send_hock_to_pass(@puck_hock, angle_to_pass, 0.5)
    # end
    
    assist_angle = @assist_hock.get_angle_to_unit(Utils.get_target_p_in_net(@assist_hock).get_unit)
    assist_speed = Point.new(@assist_hock.speed_x, @assist_hock.speed_y)
    Utils.send_hock(@assist_hock, assist_angle, ActionType::TAKE_PUCK, -assist_speed.length / 10.0)
  end
  
  def self.find_place_to_pass
    free_zone_angle = SmartUtils.find_free_zone(@assist_hock)
    # if (free_zone_angle == 2.0 * Math::PI)
      # just pass directly to the assistent
      return Point.new(@assist_hock.x, @assist_hock.y)
    # else
      # dist_pass_area = 100
      # return Utils.get_p_in_direction_from_unit(@assist_hock, free_zone_angle, dist_pass_area)
    # end

  end
  
  # @param [Point] target_p
  def self.pass_to_p_accordingly_borders(target_p)
    now_hock_angle = @puck_hock.angle
    
    # create mirror points
    points = Array.new(5)
    points[0] = target_p
    points[1] = Utils.mirror_point(target_p, Axis::X, true)
    points[2] = Utils.mirror_point(target_p, Axis::X, false)
    points[3] = Utils.mirror_point(target_p, Axis::Y, true)
    points[4] = Utils.mirror_point(target_p, Axis::Y, false)
    
    min_angle = 2 * Math::PI
    min_p_i = -1
    min_dist = GameConst::BIG_NUMBER
    i = 0
    for p_i in points do
      angle = @puck_hock.get_angle_to(p_i.x, p_i.y).abs
      if (angle <= Math::PI / 3.0)
        angle = 0.0
      end
      
      # check if this trajectory is clear
      # TODO: upgrade to check full trajectory with mirror opponents
      if (Utils.is_danger_area_clear_rot_angle(@puck_hock, angle))
      
        if (angle <= min_angle)
          dist = @puck_hock.get_distance_to(p_i.x, p_i.y)
          if (3.0 * min_dist > dist)
            # not too big distance
            min_angle = angle
            min_p_i = i
            min_dist = dist
          end
        end
      end
      i += 1
    end
    
    if (min_p_i == -1)
      return false
    end
    
    min_angle_i = min_p_i
    
    pass_p = points[min_p_i]    
    Utils.send_hock_to_p(@puck_hock, pass_p, ActionType::NONE)
    if (Utils.is_angle_to_pass(@puck_hock, pass_p))
      # puts 'pass'
      Utils.send_hock_to_pass_to_p(@puck_hock, pass_p, 0.8)
    end
    
    return true
  end
end



