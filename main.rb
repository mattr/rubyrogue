require 'gosu'
require 'input'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()
require 'noise'
require 'handler'
require 'world'

  include Interface
  include Math
  include Handler

class GameWindow < Gosu::Window
	attr_accessor :keys, :WIDTH, :HEIGHT
	Background, Base, Foreground, Overlay = *0..3 # Z levels
	WIDTH, HEIGHT = 64, 48 # width and height in tiles, based on 1024x768 with 16x16 tiles
	
# advanced initialization, not really needed now
  #~ def initialize(ini)
    #~ x=ini['Display']['DisplayX']
    #~ y=ini['Display']['DisplayY']
    #~ z=ini['Display']['Fullscreen']
    #~ super(x.to_i,y.to_i,z.to_i)
  def initialize
    super(1024, 768, 0)
    self.caption="Generic title"
    @tileset=Tileset.new(self)
    @keys=[]
    Interface::tileset=@tileset
    @update_time, @cursor_x, @cursor_y = 0, 0, 0
    @debug1=create(@debug1, Text, 0, 0, "Press 1 to generate world map", 0xFFFFFF22)
    @debug2=create(@debug2, Text, 1, 47,  '',0xFFAAAAAA)
    @seed=0
  end
    
  def update()
    start = Gosu::milliseconds() #benchmark start
    
    Inputable.input = Input::read_keys(self) #needs to come before Inputable.do!
    Inputable.do! #should come before Updatable::do!
    @keys = Inputable.input
    Updatable::do!
    
    # shows the value at camera coordinates
    @debug2.content='['+@camera.x.to_s+','+@camera.y.to_s+'] = '+@world.global[@camera.y][@camera.x].to_s if @world
    
    if Keys.triggered?(self, :'1') then 
      @debug1.remove if @debug1
      @seed += 1
      @world = create(@world, World, 32, 32, @seed)
      @camera=create(@camera, Camera, 0, 0, 20, 10, @world.map)
      @view=create(@view, Viewport,33,1,@camera)
    end
    
    @camera.x -= 1 if Keys.ready?(self, :left) and @camera.x>0
    @camera.x+= 1 if Keys.ready?(self, :right) and @camera.x<(@world.map[0].length)
    @camera.y-= 1 if Keys.ready?(self, :up) and @camera.y>0
    @camera.y+= 1 if Keys.ready?(self, :down) and @camera.y<(@world.map.length)
    
    close if Keys.triggered?(self,:esc)
    
    @update_time=Gosu::milliseconds()-start #benchmark end
  end
  
  def draw()
    start = Gosu::milliseconds() #benchmark start
    
    Drawable::do!
    
    Interface::draw_map(0,0,@world.map.length,@world.map[0].length,@world.map) if @world
    Interface::draw_tiles(@camera.x,@camera.y,1,:face_full,0xFFFFFF66) if @camera
    
    # draw_frame params: (x,y,width,height,Z, color, style) styles: :double, :single, :solid, :heart
    # draw_tiles params: (x,y,Z, symbol or array of symbols, color, :horizontal or :vertical)
    # Z order: Background, Base, Foreground, Overlay
    # draw_text(x,y,text,color) - Z always at 1 to be drawn above everything else
    # draw_buffer(x,y,width,height,buffer,off_x,off_y)

    update_draw = Gosu::milliseconds()-start #benchmark end
    self.caption = (@update_time+update_draw).to_s+" ms"
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game = GameWindow.new
Game.show