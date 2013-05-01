module CultOfGems  
  class Leader
    attr_reader :followers, :score, :max_score

    attr_accessor :intent, :impulse

    DIRECTION_DELTAS = [
        { dx:  0, dy: -1, :name => :up     },
        { dx:  1, dy:  0, :name => :right  },
        { dx:  0, dy:  1, :name => :down   },
        { dx: -1, dy:  0, :name => :left   },
      ]

    def initialize(game, image, x = 0, y = 0)
      puts "Follow the leader... "
      @game = game
      @image = image
      @followers = []
      @direction = 0

      @x = x
      @y = y
      @score = @max_score = 0

      10.times{|i| @followers << Follower.new(@game, @x, @y) }

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

      @game.map.set(@x, @y, nil)

      blocker = self.blocked?(nx,ny)
      consumed = blocker.consumed_by?(self) if blocker.kind_of?(Entity) && blocker.consumable?

      if self.blocked?(nx,ny)
        nx = @x
        ny = @y
        if @intent && [:turn_left, :turn_right].include?(@intent)
          self.send(@intent)
          @intent = nil
        else # BOOM!
          puts "CRASH!"
          @followers.each{|f| f.active = false }
          @followers.clear
          @max_score = @score if @score > @max_score
          @score >>= 1
        end
      else 
      #@new_follower = Follower.new(@game, @x, @y)
        last_follower = @followers.pop
        fx = last_follower ? last_follower.x : @x
        fx = last_follower ? last_follower.y : @y

        if @num_new_followers 
          @num_new_followers.times do
            @followers.unshift Follower.new(@game, fx, fx)
          end
          @num_new_followers = nil
        end
        if last_follower && last_follower.active?
          last_follower.warp(@x, @y)
          @followers.unshift last_follower
        end
      end

      @followers.delete_if{|f| !f.active}
      
      @score += @followers.size
      @x = nx
      @y = ny
      @game.map.set(@x, @y, self)
    end

    def blocked?(nx, ny)
      @game.map.blocked?(nx,ny)
    end

    def consume(other)
      @num_new_followers = other.num_new_followers if other.kind_of? Victim
      @score += other.consume_score
      true
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