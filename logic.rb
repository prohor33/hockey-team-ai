require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './logic'
require './utils'
require './logic_state'

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
  def self.game
    @@game
  end
  def self.game=game_tmp
    @@world = game_tmp
  end
  @@moves = Hash.new{nil}
  def self.moves
    @@moves
  end
  def self.moves=moves_tmp
    @@moves = move_tmp
  end
  
  def new_tick
    @@moves = Hash.new
    @world = @@world
    @game = @@game
    @moves = @@moves
    
    for hock in @world.hockeyists
      @moves[hock.id] = Move.new
    end
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
  end
  
  
  def defense
    # find the nearest to the puck hockeyist
    hock = Utils.find_the_nearest_player_hock_from_unit(@world.get_my_player, @world.puck)
    # send him to the puck
    @moves[hock.id].turn = hock.get_angle_to_unit(@world.puck)
    @moves[hock.id].action = ActionType::TAKE_PUCK
    @moves[hock.id].speed_up = 1.0
    # puts 'defense'
  end
  
  def attack
    # puts "attack"
    hock = Utils.find_the_nearest_hock_from_unit(@world.puck)
    @moves[hock.id].action = ActionType::STRIKE
  end

  def search
    # puts "search"
    defense
  end
end