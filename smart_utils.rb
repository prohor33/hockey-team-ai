require "./logic"
require './model/unit'
require './model/hockeyist_type'
require './utils'
require './game_const'

# Here will be function which not as straight as function in Utils
class SmartUtils
  
  # @param [Hockeyist] hock
  def self.too_close_to_strike(hock)
    rink_size_x = Logic.game.rink_right - Logic.game.rink_left
    coef = 0.3
    dist_to_net = (Logic.opponent.net_back - hock.x).abs;
    dist_to_net < coef * rink_size_x
  end
  
  # @param [Hockeyist] hock
  def self.too_far_to_strike(hock)
    rink_size_x = Logic.game.rink_right - Logic.game.rink_left
    coef = 0.5
    dist_to_net = (Logic.opponent.net_back - hock.x).abs;
    dist_to_net > coef * rink_size_x
  end
  
  # @param [Hockeyist] hock
  def self.can_smb_kick_hock(hock)
    for hock_i in Logic.world.hockeyists
      if (hock_i.player_id == Logic.me)
        next
      end
      if (hock_i.type == HockeyistType::GOALIE)
        next
      end
      if (Utils.can_hock_kick_aother_one(hock_i, hock))
        return true
      end
    end
    return false
  end
  
end