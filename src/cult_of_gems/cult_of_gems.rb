require 'gosu'

require 'cult_of_gems/leader'
#require 'cult_of_gems/follower'
#require 'cult_of_gems/enemy'
#require 'cult_of_gems/gem'
require 'cult_of_gems/game'
require 'cult_of_gems/game_window'



#require 'ruboto/util/stack'

##
# Simple snake-like game.
# Adapted from the examples in 
#  https://github.com/neochuky/gosu-android/
#
# Author: Kent Dahl <kent@rubendahl.com>
#
# Bergen Ruby Brigade (http://bergenrb.no/)
#
module CultOfGems

  module GameResources
    include Gosu
    if defined?(Ruboto)
      GAME_TILES = Ruboto::R::drawable::gametiles
      BACKGROUND = Ruboto::R::drawable::background
      KEY_MAP = {
        :left   => [ KbLeft  ],
        :right  => [ KbRight ],
        :back   => [ KbEscape ]
      }
    else
      GAME_TILES = 'res/drawable-nodpi/gametiles.png'
      BACKGROUND = 'res/drawable-nodpi/background.png'
      KEY_MAP = {
        :left   => [ Gosu::KbLeft  ],
        :right  => [ Gosu::KbRight ],
        :back   => [ KbEscape ]
      }
    end
  end

  module LayerOrder
    Background, Walls, Gems, NPC, Followers, Leader, UI = *0..7
  end


  class Entity
    attr_accessor :x, :y, :image
    attr_reader :active

    def initialize(game, x, y, image = nil, layer = nil)
      @game = game
      @x = x
      @y = y
      @image = image || @game.images[1]
      self.active = true
    end

    def warp(x,y)
      old_active = active
      self.active = false
      @x = x
      @y = y
      self.active = old_active
    end


    alias :active? active

    def active=(active)
      @game.map.set(@x, @y, (active ? self : nil)) unless @active == active
      @active = active
    end

    def draw
      @image.draw(self.x * @game.tile_width, self.y * @game.tile_height, LayerOrder::Followers) if @active
    end

    def consumable?
      false
    end

    def consumed_by?(other)
      return false unless consumable?
      was_consumed = other && other.consume(self)
      self.active = !was_consumed
      was_consumed
    end

    def consume_score
      10
    end
  end

  class Consumable < Entity
    def self.generate_random(game)
      x = rand(game.map.width)
      y = rand(game.map.height)
      return nil if (x-game.player.x)**2 + (y-game.player.y)**2 < 16  
      self.new(game, x, y, game.images[@image_type], @layer_level) unless game.map.blocked?(x,y)
    end

    def consumable?
      true
    end

    def consume_score
      100
    end

  end

  class Victim < Consumable
    @image_type = 2
    @layer_level = LayerOrder::NPC
    def consume_score
      1000
    end

    def num_new_followers
      5
    end

  end

  class Gem < Consumable
    @layer_level = LayerOrder::Gems
    @image_type = 5
    def consume_score
      5000
    end

  end

  class Follower < Entity
  end

  class Following
  end

end