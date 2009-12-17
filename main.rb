require 'gosu'
require 'keyboard'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()

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

class GameWindow < Gosu::Window
	Background, Base, Foreground, Overlay = *0..3 # Z levels
# advanced initialization, not really needed now
#  def initialize(ini)
#    x=ini['Display']['DisplayX']
#    y=ini['Display']['DisplayY']
#    z=ini['Display']['Fullscreen']
#    super(x.to_i,y.to_i,z.to_i)
  
  include Interface
  include Math

  def initialize
	super(1024,768,0)
	self.caption="Generic title"
	@tileset=Tileset.new(self)
	Interface::tileset=@tileset
	@color=Gosu::Color.new(255,255,0,0)
	@benchmark=Gosu::milliseconds()
	@buffer=[]
	64.times do |i|
		@buffer << []
		48.times do |j|
			@buffer[i][j]=[Tileset::SYMBOLS[rand(256)], COLORS.values[rand(COLORS.keys.length)]]
		end
	end
	@keys=Input.new # hash to store key presses
	@test=TextInput.new(1,28,'Test')

  end
  
  def update()
	@keys.read(self)
	puts @test.edit
	
  end
  
  def draw()
	start = Gosu::milliseconds() #benchmark start
	
	#draw_frame params: (x,y,width,height,Z, color, style) styles: :double, :single, :solid, :heart
	#draw_tiles params: (x,y,Z, symbol or array of symbols, color, :horizontal or :vertical)
	# Z order: Background, Base, Foreground, Overlay
	
	draw_frame(0,0,64,26,Foreground,0xFF999999,:single)
	draw_buffer(1,1,62,24,@buffer)
	draw_tiles(1,26,Base,"draw_buffer test",0xFFFFFFAA)
	draw_tiles(1,27,Base,@keys.inspect,0xFFFFFFFF)
	@test.draw

	delta = Gosu::milliseconds()-start #benchmark end
	self.caption=delta.to_s+" ms"
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show