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
#  def initialize(ini)
#    x=ini['Display']['DisplayX']
#    y=ini['Display']['DisplayY']
#    z=ini['Display']['Fullscreen']
#    super(x.to_i,y.to_i,z.to_i)
  def initialize
    super(1024, 768, 0)
    self.caption="Generic title"
    @tileset=Tileset.new(self)
    @keys=[]
    Interface::tileset=@tileset
    @update_time=0
    @cursor_x=0
    @cursor_y=0
    @debug1=create(@debug1,Text,0,0,"Press 1 to generate world map",0xFFFFFF22)
    @seed=0
  end
  
  
  def update()
	start = Gosu::milliseconds() #benchmark start
	
	Inputable.input=Input::read_keys(self) #needs to come before Inputable.do!
	Inputable.do! #should come before Updatable::do!
	@keys=Inputable.input
	Updatable::do!
	
	if Keys.triggered?(self,:'1') then 
		if @debug1 then @debug1.remove end
		@world=create(@world,World,40,40,@seed+=1)
	end
  
  if Keys.ready?(self,:left) and @cursor_x>0 then @cursor_x-=1 end
  if Keys.ready?(self,:right) and @cursor_x<(@world.map.length-64) then @cursor_x+=1 end
  if Keys.ready?(self,:up) and @cursor_y>0 then @cursor_y-=1 end
  if Keys.ready?(self,:down) and @cursor_y<(@world.map[0].length-48) then @cursor_y+=1 end
	
	close if Keys.triggered?(self,:esc)
	
	@update_time=Gosu::milliseconds()-start #benchmark end
  end
  
  
  
  def draw()
	start = Gosu::milliseconds() #benchmark start
	
	Drawable::do!
	
	if @world then Interface::draw_map(0,0,64,48,@world.map,@cursor_x,@cursor_y) end
	
	#draw_frame params: (x,y,width,height,Z, color, style) styles: :double, :single, :solid, :heart
	#draw_tiles params: (x,y,Z, symbol or array of symbols, color, :horizontal or :vertical)
	# Z order: Background, Base, Foreground, Overlay
	#draw_text(x,y,text,color) - Z always at 1 to be drawn above everything else
	#draw_buffer(x,y,width,height,buffer,off_x,off_y)

	update_draw = Gosu::milliseconds()-start #benchmark end
	self.caption=(@update_time+update_draw).to_s+" ms"
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show