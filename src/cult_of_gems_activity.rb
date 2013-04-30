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

  module LayerOrder
    Background, Walls, Gems, Followers, Leader, UI = *0..6
  end

  class Leader
    attr_reader :followers

    def initialize(window)
      @image = Gosu::Image.new(window, Ruboto::R::drawable::follower, false)
      # @beep = Gosu::Sample.new(window, Ruboto::R::raw::beep)
      @x = @y = @vel_x = @vel_y = @angle = 0.0
      @score = 0
    end

    def warp(x, y)
      @x, @y = x, y
    end

    def draw
      @image.draw_rot(@x, @y, LayerOrder::Leader, @angle)
    end

  end

  class GameWindow < Gosu::Window
    def initialize
      super(640, 480, false)
      self.caption = "Cult of Gems"
      
      #@background_image = Gosu::Image.new(self, Ruboto::R::drawable::space, true)
      
      @player = Leader.new(self)
      @player.warp(320, 240)

      #@star_anim = Gosu::Image::load_tiles(self, Ruboto::R::drawable::star, 25, 25, false)
      #@stars = Array.new
      
      #@font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    end

    def update
      #@player.collect_stars(@stars)
      #if rand(100) < 4 and @stars.size < 5 then
      #  @stars.push(Star.new(@star_anim))
      #end
    end

    def touch_moved(touch)
      @player.warp(touch.x, touch.y)
    end

    def draw
      #@background_image.draw(0, 0, ZOrder::Background)
      @player.draw
      #@stars.each { |star| star.draw }
      #@font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    end

    def button_down(id)
      if id == Gosu::KbEscape then
        close
      end
    end
  end

end




##
# In-game activity
#
class CultOfGemsActivity
  def on_create(bundle)
    super(bundle)
    Gosu::AndroidInitializer.instance.start(self)
  rescue Exception => e
    log_exception(e)
  end  
  
  def on_ready
    window = CultOfGems::GameWindow.new
    window.show    
  rescue Exception => e
    log_exception(e)
  end

  def log_exception(e)
    puts "#{ e } (#{ e.class } #{e.message}!"
    puts "- #{e.backtrace.join("\n- ")}"    
  end
end



require 'ruboto/widget'
require 'ruboto/util/toast'

ruboto_import_widgets :Button, :LinearLayout, :TextView

##
# Main menu of game
#
class CultOfGemsMainMenuActivity
  def onCreate(bundle)
    super
    set_title 'Cult of Gems'

    self.content_view =
        linear_layout :orientation => :vertical do
          @text_view = text_view :text => '', :width => :match_parent,
                                 :gravity => :center, :text_size => 48.0
          button :text => 'Join the Cult', :width => :match_parent,
            :on_click_listener => proc { start_game }
        end
  rescue
    puts "Exception creating activity: #{$!}"
    puts $!.backtrace.join("\n")
  end

  private

  def start_game
    toast 'Loading...'
    start_ruboto_activity class_name: 'CultOfGemsGameViewActivity'
  end

end
