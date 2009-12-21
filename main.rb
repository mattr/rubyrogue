require 'gosu'
require 'input'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()
require 'noise'
require 'handler'

COLORS={
	:white => 0xFFFFFFFF,
	:red => 0xFFFF0000,
	:green => 0xFF00FF00,
	:blue => 0xFF0000FF,
	:yellow => 0xFFFFFF00,
	:purple => 0xFFFF00FF,
	:cyan => 0xFF00FFFF,
	:gray => 0xFFAAAAAA
}

  include Interface
  include Math
  include Noise

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
    @color=Gosu::Color.new(255, 255, 0, 0)
    @update_time=0
    @keys=Input::active
    @buffer=Array.new(128){Array.new(128){[:fill100,0xFF333333]}}
    @cursor_x=0
    @cursor_y=0
    @alpha = []
  end
  
  def update()
	start = Gosu::milliseconds() #benchmark start
	Updatable::do!
	Input::read(self)
	#~ if Input.triggered?(:enter) then
		
		#~ @noise=Noise.go(8)
		#~ 64.times do |i|
			#~ 64.times do|j|
				#~ if @noise[i][j]<=-0.5 then @buffer[i][j]=[rand([:double_tilde,:"~"]),0xFF3333FF] #deep ocean
				#~ elsif @noise[i][j]>-0.5 and @noise[i][j]<= -0.25 then @buffer[i][j]=[rand([:double_tilde,:"~"]),0xFF0077FF] #not so deep sea
				#~ elsif @noise[i][j]>-0.25 and @noise[i][j]<= 0.0 then @buffer[i][j]=[rand([:double_tilde,:"~"]),0xFF00AAFF] #shallow waters
				#~ elsif @noise[i][j]>0.0 and @noise[i][j]<= 0.1 then @buffer[i][j]=[:"~",0xFFCCCC00] #coastline (sand dunes)
				#~ elsif @noise[i][j]>0.1 and @noise[i][j]<= 0.25 then @buffer[i][j]=[rand([:",",:".",:";",:":"]),rand([0xFF00FF00,0xFF33BB33,0xFF66FF66,0xFF55FF00])] # lowland grass
				#~ elsif @noise[i][j]>0.25 and @noise[i][j]<= 0.50 then @buffer[i][j]=[rand([:",",:".",:";",:":",:spade,:club,:'"',:arrow_up]),rand([0xFF00FF00,0xFF33BB33,0xFF66FF66,0xFF55FF00,0xFFCCFF33])] # lowland grass
				#~ elsif @noise[i][j]>0.5 and @noise[i][j]<= 0.75 then @buffer[i][j]=[:triangle_up,rand([0xFFCCCC33,0xFF888800,0xFFAA5511])] #hills?
				#~ else @buffer[i][j]=[:triangle_up,rand([0xFF555555,0xFF333333,0xFF777777,0xFF999999,0xFFFFFFFF])]
				#~ end
			#~ end
		#~ end
				
	#~ end
	
	#~ if Input.is_pressed?(:left) and not Input.active.include?(:right) then @cursor_x-=1
	#~ elsif Input.is_pressed?(:right) and not Input.active.include?(:left) then @cursor_x+=1
	#~ else end
	#~ if Input.is_pressed?(:up) and not Input.active.include?(:down) then @cursor_y-=1
	#~ elsif Input.is_pressed?(:down) and not Input.active.include?(:up) then @cursor_y+=1
	#~ else end
	
	if Input.triggered?(:' ') then 
		@alpha << Text.new(rand(10),rand(10),"Hello world!")
	end
	if Input.triggered?(:esc) and not @alpha.empty? then
      puts 'removing'
      obj = @alpha.pop
			Drawable::remove(obj) if obj
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
	
	#~ draw_buffer(0,0,64,48,@buffer,@cursor_x,@cursor_y)
	#~ draw_tiles(32,24,1,:fill100,0x88000000) #clear
	#~ draw_tiles(32,24,1,:face_full,0xFFCCCC33)
	#~ if @noise then 
		#~ draw_tiles(0,0,1,[:fill100]*20,0x88000000) #clear for text below
		#~ draw_text(0,0,(@cursor_x+32).to_s+"x"+(@cursor_y+24).to_s+" : "+@noise[@cursor_x+32][@cursor_y+24].to_s,0xFFCCFFFF) end

	update_draw = Gosu::milliseconds()-start #benchmark end
	self.caption=(@update_time+update_draw).to_s+" ms"
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show