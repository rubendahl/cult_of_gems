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
      @tile_height_shift = Math.log(@tile_height)/Math.log(2)
      @tile_width_shift  = Math.log(@tile_width)/Math.log(2)

      @grid_height = (window.height / @tile_height).to_i - 2
      @grid_width  = (window.width  / @tile_width).to_i - 2

      @images = Gosu::Image.load_tiles(@window, GameResources::GAME_TILES, -5, -4, true)
      @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
      @background = @window.record(@window.width, @window.height){ self.create_background } # , GameResources::SPRITES, true) 


      @player = Leader.new(self, @images[0])
      @player.warp(@grid_width/2 - 1, @grid_height -1)

    end

    def draw
      # puts "[CULT OF GEMS] [#{self.class.to_s}] Draw..."
      @background.draw(0,0,LayerOrder::Background)
      #create_background
      @player.draw

      @font.draw( "Score: #{@player.score}", 1, 1, LayerOrder::UI, 1.5, 1.5, 0xff000000 )
      @font.draw( "Score: #{@player.score}", 0, 0, LayerOrder::UI, 1.5, 1.5, 0xffffff00 )

    end

    def close
      @window.close
    end


    def create_background
      border_img = @images[2]
      mx = (@grid_width  + 1) << @tile_width_shift
      my = (@grid_height + 1) << @tile_height_shift

      (0..@grid_width).each do |x|
        px = x << @tile_width_shift
        (0..@grid_height).each do |y|
          py = y << @tile_height_shift
          border_img.draw(px,  0, LayerOrder::Background)
          border_img.draw( 0, py, LayerOrder::Background)

          border_img.draw(px, my, LayerOrder::Background)
          border_img.draw(mx, py, LayerOrder::Background)
        end
      end
    end

  end

  class Leader
    attr_reader :followers, :score

    attr_accessor :intent, :impulse

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

    def update
      if @impulse
        self.send(@impulse)
        @impulse = nil
        @intent = nil
      end
      move = DIRECTION_DELTAS[@direction]
      nx = @x + move[:dx]
      ny = @y + move[:dy]
      if nx <1 || ny < 1 || nx > @game.grid_width || ny > @game.grid_height
        if @intent && [:turn_left, :turn_right].include?(@intent)
          self.send(@intent)
          @intent = nil
        else # BOOM!
          puts "CRASH!"
          @followers.clear
        end
        return
      end
      @followers << Follower.new(@game, @x, @y)  # BAAAAD! SLOOOW! Do circular buffer instead.
      @score += @followers.size
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
      @image.draw(
          @x * @game.tile_width, 
          @y * @game.tile_height, 
          LayerOrder::Leader
        )#, @direction * 90)
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

  class Following
  end

  class GameWindow < Gosu::Window
    def initialize
      puts "[CULT OF GEMS] Creating window...."
      full_screen = true # Not working?
      super(480, 800, full_screen, 200)
      self.caption = nil # "Cult of Gems"

      @game = Game.new(self)      
    end

    def update
      @game.player.update
    end

    def draw
      # print "."
      @game.draw
      #@stars.each { |star| star.draw }
    end

    def button_down(id)
      case id
      when Gosu::KbEscape
        close
      else
        @game.player.intent=(:turn_left)  if GameResources::KEY_MAP[:left].include?(id)
        @game.player.intent=(:turn_right) if GameResources::KEY_MAP[:right].include?(id)
      end
    end


    if defined?(Ruboto)

      def touch_began(touch)
        if touch.y > @window.height >> 1
          @game.player.intent=(:turn_left) if  touch.x < @window.width >> 1
          @game.player.intent=(:turn_right) if touch.x > @window.width >> 1
        end
      end

      def touch_began(touch)
        if touch.y > @window.height >> 1
          @game.player.impulse=(:turn_left)  if touch.x < @window.width >> 1
          @game.player.impulse=(:turn_right) if touch.x > @window.width >> 1
        end
      end

    else

      def button_down(id)
        @game.player.intent=(:turn_left)  if GameResources::KEY_MAP[:left].include?(id)
        @game.player.intent=(:turn_right) if GameResources::KEY_MAP[:right].include?(id)
      end

      def button_up(id)
        @game.player.impulse=(:turn_left)  if GameResources::KEY_MAP[:left].include?(id)
        @game.player.impulse=(:turn_right) if GameResources::KEY_MAP[:right].include?(id)
        @game.close if GameResources::KEY_MAP[:back].include?(id)
        
      end

    end



  end

end