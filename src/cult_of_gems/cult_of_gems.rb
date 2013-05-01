require 'gosu'

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
    if defined?(Ruboto)
      GAME_TILES = Ruboto::R::drawable::gametiles
      KEY_MAP = {
        :left   => Gosu::KbLeft,
        :right  => Gosu::KbRight,
      }
    else
      GAME_TILES = 'res/drawable/gametiles.png'
      KEY_MAP = {
        :left   => Gosu::KbLeft,
        :right  => Gosu::KbRight,
      }
    end
  end

  module LayerOrder
    Background, Walls, Gems, NPC, Followers, Leader, UI = *0..7
  end

  class Game
    attr_reader :window 
    attr_reader :tile_width, :tile_height
    attr_reader :grid_width, :grid_height
    attr_reader :player
    attr_reader :images

    def initialize(window)
      puts ("\n" * 10) + ("="*20) + "\n[CULT OF GEMS] Creating game..."
      @window = window
      @tile_height = @tile_width = 32 # (defined?(Ruboto) ? 64 : 32) # WHAT?

      @grid_height = (window.height / @tile_height).to_i - 2
      @grid_width  = (window.width  / @tile_width).to_i - 2

      @images = nil
      #with_large_stack(128) do
      #@background = Gosu::Image.new(@window, GameResources::SPRITES, true) 
      @images = Gosu::Image.load_tiles(@window, GameResources::GAME_TILES, -5, -4, true)
      #@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
      #end

      @player = Leader.new(self, @images[0])
      @player.warp(5, 2)


      @anim_offset = 0

    end

    def draw
      # puts "[CULT OF GEMS] [#{self.class.to_s}] Draw..."
      @player.draw

      #@background.draw(50,20,LayerOrder::Background)

      #@images[@anim_offset+0 & 0x7].draw(0, 0, LayerOrder::Background)
      #@images[@anim_offset+2 & 0x7].draw(200, 0, LayerOrder::Background)
      #@images[@anim_offset+3 & 0x7].draw(0, 200, LayerOrder::Background)
      #@images[@anim_offset+4 & 0x7].draw(200, 200, LayerOrder::Background)

      @anim_offset = (@anim_offset +1 ) & 0x7

    end

  end

  class Leader
    attr_reader :followers

    attr_accessor :intent

    DIRECTION_DELTAS = [
        { dx:  0, dy: -1, :name => :up     },
        { dx:  1, dy:  0, :name => :right  },
        { dx:  0, dy:  1, :name => :down   },
        { dx: -1, dy:  0, :name => :left   },
      ]

    def initialize(game, image)
      puts "Follow the leader... "
      @game = game
      @image = image
      @followers = []
      @direction = 0

      @x = @y = 0
      @score = 0

    end

    def warp(x, y)
      @x, @y = x, y
    end

    def do_movement
      move = DIRECTION_DELTAS[@direction]
      nx = @x + move[:dx]
      ny = @y + move[:dy]
      if nx <1 || ny < 1 || nx > @game.grid_width || ny > @game.grid_height
        if @intent && [:turn_left, :turn_right].include?(@intent)
          self.send(@intent)
        else # BOOM!
          puts "CRASH!"
        end
        return
      end
      @followers << Follower.new(@game, @x, @y)  # BAAAAD! SLOOOW! Do circular buffer instead.
      # @followers.pop # Remove the last one...

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
      # puts "[CULT OF GEMS] [#{self.class.to_s}] Draw..."
      @image.draw(@x * @game.tile_width, @y * @game.tile_height, 
        LayerOrder::Leader)#, @direction * 90)

      @followers.each{|f| f.draw }
    end

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
      @image.draw( self.x * @game.tile_width, self.y * @game.tile_height, LayerOrder::Followers) if @active
    end
  end



  class GameWindow < Gosu::Window
    def initialize
      puts "[CULT OF GEMS] Creating window...."
      full_screen = true # Not working?
      super(400, 600, full_screen, 200)
      self.caption = nil # "Cult of Gems"

      @game = Game.new(self)      
    end

    def update
      @game.player.do_movement
    end

    def draw
      # print "."
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


    if defined?(Ruboto)

      def touch_began(touch)
        if touch.y > 240 
          @game.player.turn_left  if touch.x < 300
          @game.player.turn_right if touch.x > 340
        end

      end

    else

      def button_up(id)
        case id
        when GameResources::KEY_MAP[:left]
          @game.player.turn_left
        when GameResources::KEY_MAP[:right]
          @game.player.turn_right
        end
      end

    end



  end

end