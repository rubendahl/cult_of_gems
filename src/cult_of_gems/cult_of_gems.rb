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
      @view_x = self.x * @game.tile_width
      @view_y = self.y * @game.tile_height
      @active = active
    end

    def draw
      @image.draw(@view_x, @view_y, LayerOrder::Followers) if @active
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
    def initialize(leader, num_start, game, max_num = 128)
      @num_active = num_start
      @num_new_followers = 0
      @followers = []
      @game = game
      @leader = leader
      @num_active.times{|i| @followers << Follower.new(@game, leader.x, leader.y) }
    end

    def update_last_follower(x,y)
      last_follower = @followers.pop
      fx = last_follower ? last_follower.x : x
      fy = last_follower ? last_follower.y : y

      create_new_followers(fx, fy)

      if last_follower && last_follower.active?
        last_follower.warp(x, y)
        @followers.unshift last_follower
      end
    end

    def add_new_followers(num_new_followers)
      @num_new_followers += num_new_followers
    end

    def create_new_followers(fx, fy)
      @num_new_followers.times do
        @followers.unshift Follower.new(@game, fx, fy)
      end
      @num_new_followers = 0
    end

    def clear
      @followers.each{|f| f.active = false }
      @followers.clear
    end


    def draw
      @followers.each{|f| f.draw } 
    end
  end

end
