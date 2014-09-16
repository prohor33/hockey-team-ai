require "./logic"

class Utils
  
  # param [Float] x
  # param [Float] y
  def self.find_the_nearest_hock(x, y)
    min = Logic.world.width
    min_hock = nil
    for hock in Logic.world.hockeyists
      dist = hock.get_distance(x, y)
      if (dist < min)
        min = dist
        min_hock = hock
      end
    end
    hock
  end
  
  # param [Unit] unit
  def self.find_the_nearest_hock_from_unit(unit)
    find_the_nearest_hock(unit.x, unit.y)
  end
  
end