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
      KEY_MAP = {
        :left   => [ KbLeft  ],
        :right  => [ KbRight ],
        :back   => [ KbEscape ]
      }
    else
      GAME_TILES = 'res/drawable/gametiles.png'
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

  class Follower
    attr_accessor :x, :y, :active, :image
    def initialize(game, x, y, image = nil)
      @game = game
      @x = x
      @y = y
      @image = image || @game.images[1]
      @active = true
    end

    def draw
      @image.draw(self.x * @game.tile_width, self.y * @game.tile_height, LayerOrder::Followers) if @active
    end
  end

  class Following
  end

end