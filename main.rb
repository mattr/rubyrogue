require 'gosu'
require './config.rb'
require './core/display'
require './core/misc'
require './core/handler'
require './core/gradient'
require './core/constants'
require './core/input'
require './core/gui'
require './core/world'
require './core/noise'
require './read_pgm'

include Handler
include Math

class MainWindow < Gosu::Window
  attr_accessor :tileset, :keys
  def initialize
    super(SCREEN_SIZE[0],SCREEN_SIZE[1],FULLSCREEN,1.0/FPS_LIMIT)
    self.caption="Work in progress."
    @tileset=Tileset.new(self)
    @seed=0
    @heightmap=read_pgm('./images/world.pgm')
    @map=@heightmap.collect{|row| row.collect{|cell| cell=[:fill,(0xFF<<24 | cell<<16 | cell << 8 | cell)]}}
    @offset_x=0
    @offset_y=0
    @zoom=1
  end
  
def draw
    start=Gosu::milliseconds
    Drawable.do!
    
    ######### Test code begin
  
    Display.blit_map(0,0,64,48,@map,@offset_x,@offset_y,true,true,@zoom)
    
    
    ######### Test code end
    
    @draw_time=Gosu::milliseconds-start
  end
  
  def update
    start=Gosu::milliseconds()
    Inputable::input=Input::read_keys(self) #comes before Inputable.do!
    Inputable.do! # comes before Updatable.do!
    @keys=Inputable::input
    Updatable.do!
    
        @frame.width=@text.content.length+2 if @text
    
    ######### Test code begins here
    
    @offset_x-=1*@zoom if Keys.ready?(self,:left)
    @offset_x+=1*@zoom if Keys.ready?(self, :right)
    @offset_y+=1*@zoom if Keys.ready?(self, :down)
    @offset_y-=1*@zoom if Keys.ready?(self, :up)
    @zoom-=1 if Keys.triggered?(self, :'+') and @zoom > 1
    @zoom+=1 if Keys.triggered?(self, :'-')
  
    
    ######## Test code ends here
    
    self.close if Keys.triggered?(self,:esc)
    
    update_time = Gosu::milliseconds()-start #benchmark end
    total=@draw_time+update_time
    self.caption = "Draw: "+@draw_time.to_s+" ms | Logic: "+update_time.to_s+" ms | Total: "+total.to_s+" ms | FPS: "+(1000.0/total).to_s
  end
  
end

# Global variable that holds the reference to the main game window, useful for reaching it
$game=MainWindow.new
$game.show