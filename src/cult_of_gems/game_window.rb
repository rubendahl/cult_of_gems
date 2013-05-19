module CultOfGems

  class GameWindow < Gosu::Window
    def initialize
      puts "[CULT OF GEMS] Creating window...."
      full_screen = false # Not working?
      super(480, 800, full_screen, 200)
      self.caption = nil # "Cult of Gems"

      @game = Game.new(self)      
    end

    def update
      @game.update
    end

    def draw
      @game.draw
      draw_buttons
    end

    def handle_game_click(x, y, up=false)
      if y > (height >> 1)
        return @game.player.impulse=(:turn_left)  if x < width >> 1
        return @game.player.impulse=(:turn_right) if x > width >> 1
      end
    end



    if defined?(Ruboto)

      def touch_began(touch)
        handle_game_click(touch.x, touch.y)
      end

      def touch_ended(touch)
      end

    else
      
      def needs_cursor?
        true
      end

      def button_down(id)
        return @game.player.impulse=(:turn_left)  if GameResources::KEY_MAP[:left].include?(id)
        return @game.player.impulse=(:turn_right) if GameResources::KEY_MAP[:right].include?(id)
        if Gosu::MsLeft == id
          handle_game_click(mouse_x, mouse_y)
        end

      end

      def button_up(id)
        @game.close if GameResources::KEY_MAP[:back].include?(id)
      end

    end


    def draw_buttons
      midx = width >> 1 
      midy = height - 64
      topy = height - 128

      pressed = @game.player.impulse || @game.player.intent
      lcol = (pressed && pressed == :turn_left)  ? 0xFF888888 : 0xFFFFFFFF
      rcol = (pressed && pressed == :turn_right) ? 0xFF888888 : 0xFFFFFFFF


      self.draw_triangle(
          5,      midy,   0xFFFF0000 & lcol, 
          midx-5, topy,   0xFFFFBBBB & lcol, 
          midx-5, height, 0xFFFF4444 & lcol,
          LayerOrder::UI )

      self.draw_triangle(
          width-5,  midy,   0xFFFF0000 & rcol, 
          midx+5,   topy,   0xFFFFBBBB & rcol, 
          midx+5,   height, 0xFFFF4444 & rcol,
          LayerOrder::UI )
    end

  end

end