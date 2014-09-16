require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './logic'
require './utils'

require 'singleton'

class Logic
  include Singleton
  
  @@world = nil
  # getter
  def self.world
    @@world
  end
  #setter
  def self.world=world_tmp
    @@world = world_tmp
  end
  @@game
  @@move 
  
  # @param [World] world_tmp
  # @param [Game] game_tmp
  # @param [Move] move_tmp
  def run_logic(world_tmp, game_tmp, move_tmp)
    @@world = world_tmp
    @@game = game_tmp
    @@move = move_tmp
    
    hock = Utils.find_the_nearest_hock_from_unit(@@world.puck)
  end
end