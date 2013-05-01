module CultOfGems

  class GameWindow < Gosu::Window
    def initialize
      puts "[CULT OF GEMS] Creating window...."
      full_screen = true # Not working?
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


    if defined?(Ruboto)

      def touch_began(touch)
        if touch.y > @height >> 1
          @game.player.intent=(:turn_left) if  touch.x < @width >> 1
          @game.player.intent=(:turn_right) if touch.x > @width >> 1
        end
      end

      def touch_ended(touch)
        if touch.y > @height >> 1
          @game.player.impulse=(:turn_left)  if touch.x < @width >> 1
          @game.player.impulse=(:turn_right) if touch.x > @width >> 1
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


    def draw_buttons
      midx = width >> 1
      midy = height - 32
      topy = height - 64

      pressed = @game.player.impulse || @game.player.intent
      lcol = (pressed && pressed == :turn_left) ?  0xFF888888 : 0xFFFFFFFF
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