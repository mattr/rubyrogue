require 'gosu'
require 'input'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()
require 'noise'
require 'handler'

  include Interface
  include Math
  include Noise
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
    Interface::tileset=@tileset
    @update_time=0
    @buffer=Array.new(128){Array.new(128){[:fill100,0xFF333333]}}
    @cursor_x=0
    @cursor_y=0
    @debug1=create(@debug1,Text,0,0,"Press  ,  ,   or   to show stuff,       to remove them all",0xFFFFFF22)
    @debug2=create(@debug2,Text,0,0,"      1  2  3    4                Space",0xFF22FFFF)
  end
  
  
  def update()
	start = Gosu::milliseconds() #benchmark start
	
	Inputable.input=Input::read_keys(self) #needs to come before Inputable.do!
	Inputable.do! #should come before Updatable::do!
	Updatable::do!
	
	if Input.triggered?(:'1') then 
		@alpha=create(@alpha,Text,28,24,"Ho ho ho")
	end
	if Input.triggered?(:'2') then 
		@beta=create(@beta,Tile,28,25,0,[:heart]*8,0xFFFF2222,:horizontal)
	end
	if Input.ready?(:'3') then
		@gamma=create(@gamma,Frame,27,23,10,5,0,0xFFFF0000,rand([:heart,:fill,:double,:single,:box,:face_full,:face_empty,:ring]))
	end
	if Input.triggered?(:'4') then
		@delta=create(@delta,Text,2,10,'Press e to edit this text')
	end
	if Inputable.input.include?(:E) and Input.triggered?(:E) and @delta then
		@phi=create(@phi,TextInput,@delta)
	end		
	if Inputable.input.include?(:' ') and Input.triggered?(:' ') then
		Handler.remove(@alpha,@beta,@gamma,@delta,@phi)
	end
	
	@update_time=Gosu::milliseconds()-start #benchmark end
  end
  
  
  
  def draw()
	start = Gosu::milliseconds() #benchmark start
	
	Drawable::do!
	
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