require 'gosu'
require './config.rb' # configuration file
require './misc.rb'
require './constants.rb'
require './handler.rb'
require './display.rb'
require './input.rb'
require './layout.rb'
require './gui.rb'

include Handler
include Math

class MainWindow < Gosu::Window
  attr_accessor :tileset, :keys, :timedelta, :current_layout
  def initialize
    super(SCREEN_SIZE[0],SCREEN_SIZE[1],FULLSCREEN,1.0/FPS_LIMIT)
    self.caption="Work in progress."
    @tileset=Tileset.new(self)
  end
  
  def draw
    start = Gosu::milliseconds()
    Drawable.do!
    
    ######### Test code begin
    
    ######### Test code end
    
    @draw_time = Gosu::milliseconds() - start
  end
  
  def update
    start = Gosu::milliseconds()
    Inputable::input=Input::read_keys(self) #comes before Inputable.do!
    Inputable.do! # comes before Updatable.do!
    @keys=Inputable::input
    Updatable.do!
    
    ######### Test code begins here
    @current_layout ||= Title.new # start with Title layout if no layout is loaded yet. Don't put into initialize.
    

    ######## Test code ends here
    @update_time = Gosu::milliseconds() - start #benchmark end
    @timedelta=@draw_time + @update_time

  end
  
  def change_layout(target)
    if target == @current_layout.class then return nil end # Ignore if same class
    @current_layout=target.new if target.superclass == Layout # create the new layout
  end
  
  def quit #might add some cleanup code here later, so it is a method on its own
    self.close
  end
end

# Global variable that holds the reference to the main game window, useful for reaching it
$game=MainWindow.new
$game.show