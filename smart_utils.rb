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
      if (hock_i.player_id == Logic.me.id)
        next
      end
      if (hock_i.type == HockeyistType::GOALIE)
        next
      end
      if (Utils.can_hock_kick_another_one(hock_i, hock))
        return true
      end
    end
    return false
  end
  
  # @param [Hockeyist] hock
  def self.find_free_zone(hock)
    zone_size = GameConst::AREA_SIZE + 100
    zone_angle = Math::PI / 10.0
    angle_delta = Math::PI / 50.0
    angle_i = -Math::PI
    while angle_i < Math::PI do
      
      area_is_not_good = false
      
      dir_p = Utils.get_p_in_direction_from_unit(hock, angle_i - hock.angle, zone_size)
      if (Utils.is_p_out_of_rink(dir_p))
        area_is_not_good = true
      end
      
      if (!area_is_not_good)
        for hock_i in Logic.world.hockeyists
          if (hock_i.player_id == Logic.me.id)
            next
          end
          if (hock_i.type == HockeyistType::GOALIE)
            next
          end
          if (Utils.is_unit_in_the_hock_area_spec_rot_angle(hock, hock_i, zone_size, zone_angle, angle_i))
            area_is_not_good = true
            break
          end
        end
      end
      
      if (!area_is_not_good)
        return angle_i
      end
      
      angle_i += angle_delta
    end
    
    return 2.0 * Math::PI # no free zone
  end
  
end