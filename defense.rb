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

class Defense
  @attacker = nil
  @defender = nil
  @skip_next_iteration = false
  
  def self.start # Call before first iteration after other state
    @attacker = Utils.find_the_nearest_player_hock_from_unit(Logic.world.get_my_player, Logic.puck)
    @defender = Utils.get_my_other_hock(@attacker)
    
    @skip_next_iteration = Utils.cancel_strike(@attacker) || Utils.cancel_strike(@defender)
  end
  
  def self.iter
    # Update hockeyist
    @attacker = Utils.find_the_nearest_player_hock_from_unit(Logic.world.get_my_player, Logic.puck)
    @defender = Utils.get_my_other_hock(@attacker)
    # puts 'defense'
    if (@skip_next_iteration)
      @skip_next_iteration = false
      puts 'return'
      return
    end
     # attacker goes to the puck
    Utils.send_hock_to_unit(@attacker, Logic.puck, ActionType::TAKE_PUCK)
    
    # if attacker are able to kick => kick
    if (Utils.is_unit_in_the_hock_area(@attacker, Logic.puck) || Utils.can_kick_someone(@attacker))
      Utils.send_hock_to_unit(@attacker, Logic.puck, ActionType::STRIKE)  
    end
    
    # defender stays in the middle
    net_p = Utils.get_player_net_p(Logic.me)
    point_coef = 0.5
    if (Utils.is_playing_without_goalies)
      point_coef = 0.7
    end
    defend_p = Utils.get_point_between_two_points(Point.from_unit(Logic.puck), net_p, point_coef)
    Utils.send_hock_to_p_with_slow_down(@defender, defend_p, ActionType::TAKE_PUCK)
    
    # if defender are able to kick => kick
    if (Utils.can_kick_someone(@defender))
      Utils.send_hock_to_unit(@defender, Logic.puck, ActionType::STRIKE)  
    end
  end
end