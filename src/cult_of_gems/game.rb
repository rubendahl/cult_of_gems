module CultOfGems

  class Game
    
    attr_reader :window, :map
    attr_reader :tile_width, :tile_height
    attr_reader :grid_width, :grid_height
    attr_reader :player
    attr_reader :images

    def initialize(window)
      puts ("\n" * 10) + ("="*20) + "\n[CULT OF GEMS] Creating game..."
      @window = window

      @background = nil
      #with_large_stack(512) do
      # @background = Gosu::Image.new(@window, GameResources::BACKGROUND, true)
      #end

      
      @tile_height = @tile_width = 32 # (defined?(Ruboto) ? 64 : 32) # WHAT?
      @tile_height_shift = Math.log(@tile_height)/Math.log(2)
      @tile_width_shift  = Math.log(@tile_width)/Math.log(2)


      @grid_height = (window.height / @tile_height).to_i - 2 - 4
      @grid_width  = (window.width  / @tile_width).to_i - 2 

      @map = Map.new(self, @grid_width, @grid_height)

      @images = Gosu::Image.load_tiles(@window, GameResources::GAME_TILES, -5, -5, true)
      @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)

      # @background = @window.record(@window.width, @window.height){ self.create_background }
      # @background.save("res/drawable/background-cached.png") if @background && !defined?(Ruboto)

      precalc_draw_background_color

      @player = Leader.new(self, @images[0])
      @player.warp(@grid_width/2 - 1, @grid_height -1)

      @gems     = []
      @victims  = []
      @enemies = []

    end


    def update
      @player.update

      if rand(100) < 20 && @victims.size < 32
        @victims.delete_if{|i| !i.active }
        victim = Victim.generate_random(self)
        @victims << victim if victim
      else 
        @victims.delete_if{|i| !i.active }
      end

      if rand(100) < 10 && @gems.size < 8
        @gems.delete_if{|i| !i.active }
        gem = Gem.generate_random(self)
        @gems << gem if gem
      end

    end


    def draw
      # puts "[CULT OF GEMS] [#{self.class.to_s}] Draw..."
      if @background
        @background.draw(0,0,LayerOrder::Background)
      else
        draw_background_color
      end
      @player.draw
      @victims.each{|f| f.draw }
      @gems.each{|f| f.draw }


      score_str = "Score: #{@player.score} - Record: #{@player.max_score}"
      @font.draw( score_str, 1, 1, LayerOrder::UI, 1, 1, 0xff000000 )
      @font.draw( score_str, 0, 0, LayerOrder::UI, 1, 1, 0xffffff00 )

    end

    def close
      @window.close
    end


    def create_background
      border_img = @images[15]
      back_imgs  = [11,11,11,10,12,12,12,10].collect{|i| @images[i]}

      layer = LayerOrder::Background
      mx = (@grid_width  + 1) << @tile_width_shift
      my = (@grid_height + 1) << @tile_height_shift

      (0..@grid_width+1).each do |x|
        px = x << @tile_width_shift
        (0..@grid_height).each do |y|
          py = y << @tile_height_shift
          border_img.draw(px,  0, layer)
          border_img.draw( 0, py, layer)

          back_imgs[ y & 7 ].draw(px, py, layer)

          border_img.draw(px, my, layer)
          border_img.draw(mx, py, layer)
        end
      end
    end

    def precalc_draw_background_color
      layer = LayerOrder::Background

      ox = @tile_width
      oy = @tile_height
      mx = (@grid_width  + 1) << @tile_width_shift
      my = (@grid_height + 1) << @tile_height_shift

      @bg_draw = [
        [
          0,              0,              0xFFAAAAAA,
          @window.width,  0,              0xFF888888,
          0,              @window.height, 0xFF666666,
          @window.width,  @window.height, 0xFF444444,
          layer
        ],
        [
          ox, oy, 0xFF888888,
          mx, oy, 0xFF666666,
          ox, my, 0xFF444444,
          mx, my, 0xFF222222,
          layer
        ]
      ]
    end

    def draw_background_color
      @window.draw_quad(*@bg_draw.first)
      @window.draw_quad(*@bg_draw.last)
    end


  end


  class Map
    attr_reader :game, :width, :height
    def initialize(game, width, height)
      @width  = width
      @height = height
      @grid = (0..width).collect do
       (0..height).collect{ nil }  
      end
    end

    def blocked?(x,y)
      return true if x <1 || y < 1 || x > @width || y > @height

      column = @grid[x]
      found = column && column[y]
      found
    end

    def set(x,y,obj)
      column = @grid[x]
      return column[y] = obj if column && y < column.size
      nil
    end

    def set?(x,y,obj)
      return nil if blocked?(x,y)
      set(x,y,obj)
    end

  end

end