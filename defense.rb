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
    # @attacker = Utils.get_hock_by_id(@attacker.id)
    # @defender = Utils.get_hock_by_id(@defender.id)
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
    net_p = Point.new(Logic.me.net_back, (Logic.me.net_top + Logic.me.net_bottom) / 2.0)
    defend_p = Utils.get_middle_between_two_points(Point.from_unit(Logic.puck), net_p)
    Utils.send_hock_to_p(@defender, defend_p, ActionType::TAKE_PUCK)
    
    # if defender are able to kick => kick
    if (Utils.can_kick_someone(@defender))
      Utils.send_hock_to_unit(@defender, Logic.puck, ActionType::STRIKE)  
    end
  end
end