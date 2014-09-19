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
  
  @@me = nil
  def self.me
    @@me
  end

  def new_tick
    @@moves = Hash.new
    @world = @@world
    @game = @@game
    @moves = @@moves
    @@me = @world.get_my_player
    @me = @@me

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
    attacker = Utils.find_the_nearest_player_hock_from_unit(@world.get_my_player, @world.puck)
    Utils.send_hock_to_unit(attacker, @world.puck, ActionType::TAKE_PUCK)
    
    # puts attacker.id
    defender = Utils.get_other_hock(attacker)
    net_p = Point.new(@me.net_back, (@me.net_top + @me.net_bottom) / 2.0)
    defend_p = Utils.get_middle_between_two_points(Point.from_unit(@world.puck), net_p)
    Utils.send_hock_to_p(defender, defend_p, ActionType::TAKE_PUCK)
  # puts 'defense'
  end

  def attack
    # puts "attack"
    hock = Utils.find_the_nearest_player_hock_from_unit(@me, @world.puck)
    @moves[hock.id].action = ActionType::STRIKE
  end

  def search
    # puts "search"
    defense
  end
end