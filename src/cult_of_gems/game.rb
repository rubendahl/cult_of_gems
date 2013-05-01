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
      
      @tile_height = @tile_width = 32 # (defined?(Ruboto) ? 64 : 32) # WHAT?
      @tile_height_shift = Math.log(@tile_height)/Math.log(2)
      @tile_width_shift  = Math.log(@tile_width)/Math.log(2)

      @grid_height = (window.height / @tile_height).to_i - 2
      @grid_width  = (window.width  / @tile_width).to_i - 2

      @map = Map.new(self, @grid_width, @grid_height)

      @images = Gosu::Image.load_tiles(@window, GameResources::GAME_TILES, -5, -4, true)
      @font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
      @background = @window.record(@window.width, @window.height){ self.create_background } # , GameResources::SPRITES, true) 


      @player = Leader.new(self, @images[0])
      @player.warp(@grid_width/2 - 1, @grid_height -1)

      @gems     = []
      @victims  = []
      @enemies = []

    end

    def draw
      # puts "[CULT OF GEMS] [#{self.class.to_s}] Draw..."
      @background.draw(0,0,LayerOrder::Background)
      #create_background
      @player.draw

      score_str = "Score: #{@player.score} - Record: #{@player.max_score}"
      @font.draw( score_str, 1, 1, LayerOrder::UI, 1.5, 1.5, 0xff000000 )
      @font.draw( score_str, 0, 0, LayerOrder::UI, 1.5, 1.5, 0xffffff00 )

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


  class Map
    attr_reader :game
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
      return column[y] = obj if y < column.size
      nil
    end

    def set?(x,y,obj)
      return nil if blocked?(x,y)
      set(x,y,obj)
    end

  end

end