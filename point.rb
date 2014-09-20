require './model/unit'

class Point
  # @return [Float]
  attr_accessor :x
  
  # @return [Float]
  attr_accessor :y
  
  # param [Float] x
  # param [Float] y
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  # param [Point] p
  def self.from_point(p)
    Point.new(p.x, p.y)
  end
  
  # param [Unit] unit
  def self.from_unit(unit)
    Point.new(unit.x, unit.y)
  end
  
  # param [Point] p
  def +(p)
    Point.new(@x + p.x, @y + p.y)
  end
  
  # # param [Point] p
  # def +=(p)
    # @x += p.x
    # @y += p.y
    # self
  # end
  
  # param [Point] p
  def -(p)
    Point.new(@x - p.x, @y - p.y)
  end
  
  # # param [Point] p
  # def -=(p)
    # @x -= p.x
    # @y -= p.y
    # self
  # end
  
  # param [Float] p
  def *(coef)
    Point.new(@x * coef, @y * coef)
  end
  
  # param [Float] p
  def /(coef)
    Point.new(@x / coef, @y / coef)
  end
  
  def get_unit()
    Unit.new(0, 0, 0, @x, @y, 0, 0, 0, 0)
  end
  

end