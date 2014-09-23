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
require './smart_utils'
require './axis'

module AttackStrategy
  ATTACK = 0
  GET_RID_OF_PUCK = 1
  OVERTIME = 2
end

class Attack  
  @puck_hock = nil
  @assist_hock = nil
  
  @strategy = -1
  
  def self.start
    @strategy = -1
    decide    
  end
  
  def self.decide # Decide strategy
    puts 'decide'
    
    decide_on_start = @strategy == -1
    
    @puck_hock = Utils.find_the_nearest_player_hock_from_unit(Logic.world.get_my_player, Logic.puck)
    @assist_hock = Utils.get_my_other_hock(@puck_hock)
    
    # Observer situation
    is_danger = false
    if (decide_on_start)
      is_danger = SmartUtils.can_smb_kick_hock(@puck_hock)
    end

    if (is_danger)
      # need to get rid of the puck
      @strategy = AttackStrategy::GET_RID_OF_PUCK
      puts 'decide to get rid of the puck'
    else
      # just go forward
      @strategy = AttackStrategy::ATTACK
      puts 'decide to attack'
    end
 
    if (Utils.is_overtime)
      @strategy = AttackStrategy::OVERTIME
      puts 'overtime!'
    end
  end
  
  def self.iter        
    case @strategy
    when AttackStrategy::ATTACK
      attack
    when AttackStrategy::GET_RID_OF_PUCK
      get_rid_of_puck
    when AttackStrategy::OVERTIME
      overtime_strategy
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
    
    if (too_far_to_strike)
      good_strike_p = get_good_strike_p(@puck_hock)
      if (good_strike_p.x == -1)
        too_far_to_strike = false
      end      
      Utils.send_hock_to_p(@puck_hock, good_strike_p, ActionType::NONE)
    end
    # too_far_to_strike = false # to debug!

    if (!too_far_to_strike)
 
      Utils.send_hock_to_p(@puck_hock, net_target_p, ActionType::NONE)
      
      need_to_strike = false
      
      if (Utils.is_angle_to_strike(@puck_hock, net_target_p))
        Utils.send_hock_to_p(@puck_hock, net_target_p, ActionType::SWING)
        
        if (too_close_to_strike)
          need_to_strike = true
        end
        if (SmartUtils.can_smb_kick_hock(@puck_hock))
          need_to_strike = true
        end
        
        # puts 'last action = ' + @puck_hock.last_action.to_s
        if (@puck_hock.last_action == ActionType::SWING)
          last_action_time_lef = Logic.game.tick_count - @puck_hock.last_action_tick
          puts 'swing ticks: ' + @puck_hock.swing_ticks.to_s + ' of ' + Logic.game.max_effective_swing_ticks.to_s
          if (@puck_hock.swing_ticks >= Logic.game.max_effective_swing_ticks)
            need_to_strike = true
          end
        end
      else
        # angle start to become not good
        if (@puck_hock.last_action == ActionType::SWING)
            need_to_strike = true
        end
      end
      
      if (need_to_strike)
        Utils.send_hock_to_p(@puck_hock, net_target_p, ActionType::STRIKE)
      end
    
    end

    # other hock stays in the middle
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
  
  # @param [Hockeyist] hock
  def self.get_good_strike_p(hock)
    rink_center_p = Point.new(0, 0)
    rink_center_p.x = (Logic.game.rink_right + Logic.game.rink_left) / 2.0
    target_right = Logic.opponent.net_back > rink_center_p.x
    rink_center_p.y = (Logic.game.rink_bottom + Logic.game.rink_top) / 2.0
    target_down = hock.y > rink_center_p.y
    
    shift_x = Utils.get_rink_size.x * 1.0 / 6.0
    shift_y = Utils.get_rink_size.y * 2.0 / 5.0
    shift_p = Point.new(target_right ? shift_x : -shift_x, target_down ? shift_y : -shift_y)
    
    rink_center_p + shift_p    
  end
  
  def overtime_strategy
    @puck_hock = Utils.get_hock_by_id(@puck_hock.id)
    @assist_hock = Utils.get_hock_by_id(@assist_hock.id)
    need_to_strike = false
    
    net_center_p = Utils.get_player_net_p    
    acc_angle = Math.atan(Utils.get_player_net_size.y / 2.0 / @puck_hock.get_distance_to(net_center_p.x, net_center_p.y))
    if (Utils.is_angle_to_strike_with_accuracy(@puck_hock, net_center_p, acc_angle))
      need_to_strike = true
    end
    
    Utils.send_hock_to_p(@puck_hock, net_center_p, ActionType::TAKE_PUCK)
    
    if (need_to_strike)
      Utils.send_hock_to_p(@puck_hock, net_center_p, ActionType::STRIKE)
    end
    
    # other hock stays in closer to the net
    net_p = Utils.get_player_net_p(Logic.me)
    defend_p = Utils.get_point_between_two_points(Point.from_unit(Logic.puck), net_p, 0.7)
    Utils.send_hock_to_p(@assist_hock, defend_p, ActionType::TAKE_PUCK)
  end
  
end




