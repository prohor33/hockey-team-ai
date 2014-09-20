require "./logic"
require './model/unit'
require './model/hockeyist_type'

# Here will be function which not as straight as function in Utils
class SmartUtils
  
  # @param [Hockeyist] hock
  def self.too_close_to_strike(hock)
    on_rink_x = hock.x - Logic.game.rink_left
    rink_size_x = Logic.game.rink_right - Logic.game.rink_left
    coef = 0.3
    on_rink_x < coef * rink_size_x
  end
  
  # @param [Hockeyist] hock
  def self.too_far_to_strike(hock)
    on_rink_x = hock.x - Logic.game.rink_left
    rink_size_x = Logic.game.rink_right - Logic.game.rink_left
    coef = 0.5
    on_rink_x > coef * rink_size_x
  end
  
end