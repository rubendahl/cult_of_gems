require 'cult_of_gems/cult_of_gems'


##
# In-game activity
#
class CultOfGemsGameViewActivity
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
    # Gosu::AndroidInitializer.instance.start(self)

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


start_immediately = true
if start_immediately then
  class CultOfGemsActivity < CultOfGemsGameViewActivity ; end
else
  class CultOfGemsActivity < CultOfGemsMainMenuActivity ; end
end
