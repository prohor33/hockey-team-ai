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
    is_danger = !Utils.is_danger_area_clear(@puck_hock)
    
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
    
    net_p = Utils.get_player_net_p(Logic.world.get_opponent_player)
    net_size = Utils.get_player_net_size(Logic.world.get_opponent_player)
    attack_p = net_p + net_size / 2.0
 
    Utils.send_hock_to_p(@puck_hock, attack_p, ActionType::SWING)
    
    if (@puck_hock.last_action == ActionType::SWING)
      last_action_time_lef = Logic.game.tick_count - @puck_hock.last_action_tick
      if (@puck_hock.swing_ticks >= Logic.game.max_effective_swing_ticks)
        Mover.moves[@puck_hock.id].action = ActionType::STRIKE
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
    Utils.send_hock(@puck_hock, 0, ActionType::STRIKE, 0)
  end

end




