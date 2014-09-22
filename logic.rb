require './model/action_type'
require './model/game'
require './model/move'
require './model/hockeyist'
require './model/world'
require './model/unit'
require './utils'
require './logic_state'
require './point'
require './defense'
require './search'
require './attack'
require './mover'

class Logic
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
  @@opponent = nil
  def self.opponent
    @@opponent
  end
  
  @@old_state = LogicState::NONE

  def self.new_tick
    Mover.new_tick
    @world = @@world
    @game = @@game
    @@me = @world.get_my_player
    @@opponent = @world.get_opponent_player
    @me = @@me 
    @@puck = @world.puck
    @puck = @@puck    
  end

  # @param [World] world_tmp
  # @param [Game] game_tmp
  # @param [Move] move_tmp
  def self.run_logic(world, game)
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

  def self.defense
    # puts 'defense'
    if (@@old_state != LogicState::DEFENSE)
      Defense.start
    end
    Defense.iter
  end

  def self.attack
    if (@@old_state != LogicState::ATTACK)
      Attack.decide
    end
    Attack.iter
  end

  def self.search
    # puts 'search'
    if (@@old_state != LogicState::SEARCHING)
      Search.start
    end
    Search.iter
  end
end






