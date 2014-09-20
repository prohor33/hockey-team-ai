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
require './defense'
require './search'
require './attack'

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
  
  @@game = nil
  def self.game
    @@game
  end
  def self.game=game_tmp
    @@world = game_tmp
  end
  
  @@puck = nil
  def self.puck
    @@puck
  end
  
  @@me = nil
  def self.me
    @@me
  end
  
  @@old_state = LogicState::NONE

  def new_tick
    Mover.new_tick
    @world = @@world
    @game = @@game
    @@me = @world.get_my_player
    @me = @@me 
    @@puck = @world.puck
    @puck = @@puck    
  end

  # @param [World] world_tmp
  # @param [Game] game_tmp
  # @param [Move] move_tmp
  def run_logic(world, game)
    @@world = world
    @@game = game
    new_tick

    if (@world.puck.owner_player_id == @world.get_my_player.id)
      @state = LogicState::ATTACK
    elsif (@world.puck.owner_player_id == @world.get_opponent_player.id)
      @state = LogicState::DEFENSE
    else
      @state = LogicState::SEARCHING
    end

    case @state
    when LogicState::DEFENSE
      defense
    when LogicState::ATTACK
      attack
    when LogicState::SEARCHING
      search
    else
    puts "error state"
    end
    
    @@old_state = @state
  end

  def defense
    # puts 'defense'
    if (@@old_state != LogicState::DEFENSE)
      Defense.start
    end
    Defense.iter
  end

  def attack
    if (@@old_state != LogicState::ATTACK)
      Attack.decide
    end
    Attack.iter
  end

  def search
    # puts 'search'
    if (@@old_state != LogicState::SEARCHING)
      Search.start
    end
    Search.iter
  end
end






