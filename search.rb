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

class Search
  @finder = nil
  @defender = nil
  @skip_next_iteration = false
  
  def self.start # Call before first iteration after other state
    @finder = Utils.find_the_nearest_player_hock_from_unit(Logic.world.get_my_player, Logic.puck)
    @defender = Utils.get_my_other_hock(@finder)
    
    @skip_next_iteration = Utils.cancel_strike(@finder) || Utils.cancel_strike(@defender)
  end
  
  def self.iter
    # Update hockeyist
    # @finder = Utils.get_hock_by_id(@finder.id)
    # @defender = Utils.get_hock_by_id(@defender.id)
    @finder = Utils.find_the_nearest_player_hock_from_unit(Logic.world.get_my_player, Logic.puck)
    @defender = Utils.get_my_other_hock(@finder)
    if (@skip_next_iteration)
      @skip_next_iteration = false
      puts 'return'
      return
    end
     # finder goes to the puck
    Utils.send_hock_to_unit(@finder, Logic.puck, ActionType::TAKE_PUCK)
    
    # defender stays in the middle
    net_p = Point.new(Logic.me.net_back, (Logic.me.net_top + Logic.me.net_bottom) / 2.0)
    defend_p = Utils.get_middle_between_two_points(Point.from_unit(Logic.puck), net_p)
    Utils.send_hock_to_p_with_slow_down(@defender, defend_p, ActionType::TAKE_PUCK)
    
    # if defender are able to kick => kick
    if (Utils.can_kick_someone(@defender))
      Utils.send_hock_to_unit(@defender, Logic.puck, ActionType::STRIKE)  
    end
  end
end