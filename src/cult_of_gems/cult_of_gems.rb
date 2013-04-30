require 'gosu'

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
    if defined?(Ruboto)
      GAME_TILES = Ruboto::R::drawable::gametiles
    else
      GAME_TILES = 'res/drawable/gametiles.png'
    end
  end

  module LayerOrder
    Background, Walls, Gems, NPC, Followers, Leader, UI = *0..7
  end

  class Game
    attr_reader :window, :tile_width, :tile_height
    attr_reader :player
    attr_reader :images

    def initialize(window)
      @window = window
      @tile_height = @tile_width = 32

      @images = Gosu::Image.load_tiles(@window, GameResources::GAME_TILES, @tile_width, @tile_height, false)

      @player = Leader.new(self, @images[0])
      @player.warp(5, 2)

    end

    def draw
      @player.draw
    end

  end

  class Leader
    attr_reader :followers

    DIRECTION_DELTAS = [
        { dx:  0, dy: -1, :name => :up     },
        { dx:  1, dy:  0, :name => :right  },
        { dx:  0, dy:  1, :name => :down   },
        { dx: -1, dy:  0, :name => :left   },
      ]

    def initialize(game, image)
      @game = game
      @image = image # Gosu::Image.new(@game.window, GameResources::FOLLOWER, false)
      # @beep = Gosu::Sample.new(window, Ruboto::R::raw::beep)
      @followers = []
      @direction = 0

      @x = @y = 0.0
      @score = 0

    end

    def warp(x, y)
      @x, @y = x, y
    end

    def do_movement
      move = DIRECTION_DELTAS[@direction]
      nx = @x + move[:dx]
      ny = @y + move[:dy]
      return if nx <0 || ny < 0 || nx > 20 || ny > 15
      @followers.unshift([nx,ny])  # BAAAAD! SLOOOW!
      # @followers.pop

      @x = nx
      @y = ny
    end

    def turn_left
      @direction = (@direction - 1 ) & 0x3
    end

    def turn_right
      @direction = (@direction + 1 ) & 0x3
    end

    def draw
      @image.draw_rot(@x * @game.tile_width, @y * @game.tile_height, LayerOrder::Leader, @direction * 90)

      @followers.each{|x,y| 
        @game.images[1].draw_rot(x * @game.tile_width, y * @game.tile_height, 
          LayerOrder::Followers, @direction * 45)
      }

    end

  end

  class GameWindow < Gosu::Window
    def initialize
      full_screen = false # Not working?
      super(640, 480, full_screen, 200)
      self.caption = "Cult of Gems"

      @game = Game.new(self)
      
      #@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    end

    def update
      @game.player.do_movement
    end

    def touch_began(touch)
      if touch.y > 240 
        @game.player.turn_left  if touch.x < 300
        @game.player.turn_right if touch.x > 340
      end

    end

    def touch_moved(touch)
      # @game.player.warp(touch.x, touch.y)
    end

    def draw
      @game.draw
      #@stars.each { |star| star.draw }
      #@font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    end

    def button_down(id)
      case id
      when Gosu::KbEscape
        close
      end
    end

    def button_up(id)
      case id
      when Gosu::MsLeft, Gosu::KbLeft
        @game.player.turn_left
      when Gosu::MsRight, Gosu::KbRight
        @game.player.turn_right
      end
    end


  end

end