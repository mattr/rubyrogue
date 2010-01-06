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
    
    #change to :file if you want to load from the height map file, don't forget to change dimensions to 513,513
    @world=World.new(:random,32,32)

    @zoom=1
    @world.x,@world.y=@world.width/2,@world.height/2
    @world.update_regions(@world.x,@world.y)
   
  end
  
def draw
    start=Gosu::milliseconds
    Drawable.do!
    
    ######### Test code begin
  
    Display.blit_map(0,0,32,32,@world.map,@world.x-16,@world.y-16,true,false,@zoom) #we want the 'current' region to be in middle of world view
    Display.blit_map(32,0,32,32,@world.regions[1][1].map,0,0,false,false)
    Display.blit(16,16,1,:face_full,0xFFFFFFFF)
    
    
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
    
  if Keys.ready?(self, :left) and @world.region_left.passable then
    @world.move(:left)
  end
  if Keys.ready?(self, :right) and @world.region_right.passable then
    @world.move(:right)
  end
  if Keys.ready?(self, :up) and @world.region_up.passable then
    @world.move(:up)
  end
  if Keys.ready?(self, :down) and @world.region_down.passable then
    @world.move(:down)
  end
  
  
    #~ @zoom-=1 if Keys.triggered?(self, :'+') and @zoom > 1
    #~ @zoom+=1 if Keys.triggered?(self, :'-')
    
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