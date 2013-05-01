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
      @game.player.update
    end

    def draw
      @game.draw
    end


    if defined?(Ruboto)

      def touch_began(touch)
        if touch.y > @window.height >> 1
          @game.player.intent=(:turn_left) if  touch.x < @window.width >> 1
          @game.player.intent=(:turn_right) if touch.x > @window.width >> 1
        end
      end

      def touch_ended(touch)
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