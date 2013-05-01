module CultOfGems  
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
          @score >>= 1
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

end