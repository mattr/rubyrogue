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

include Handler
include Math

class MainWindow < Gosu::Window
  attr_accessor :tileset, :keys
  def initialize
    super(SCREEN_SIZE[0],SCREEN_SIZE[1],FULLSCREEN,1.0/FPS_LIMIT)
    self.caption="Work in progress."
    @tileset=Tileset.new(self)
    @seed=0
    @offset=0
  end
  
  def draw
    start=Gosu::milliseconds
    Drawable.do!
    
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
    
    
    @offset=(@offset+0.1)%32
    @map1.offset_x=@map2.offset_x=@offset.to_i if @world
    
    if Keys.triggered?(self,:enter) then
      @seed+=1
      @world=create(@world,World, 32, 32, @seed)
      @map1=create(@map1, View, 0, 0, 32, 32, @world.map, 0,0,true,false)
      @map2=create(@map2, View, 32, 0, 32, 32, @world.heightmap, 0,0,true,false)
      @text1=create(@text1, Text, 1, 32, 'Color map', 0xFFAAAAAA)
      @text2=create(@text2, Text, 33, 32, 'Height map', 0xFFAAAAAA)
      @line=create(@line, Frame, 0, 33, 64, 1, 0, 0xFF888888,:fill100)
    end
    
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