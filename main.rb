require 'gosu'
require 'keyboard'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()

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
    @color=Gosu::Color.new(255,255,0,0)
    @hash={
    [1,1] => [Base,:face_full,0xFF00FF00]
    }
  end
  
  def update()
	@color.red=128+(sin(Gosu::milliseconds.to_f/200)*127).to_i
	rand(10).times do 
		@hash[[rand(65),rand(48)]]=[Base,Tileset::SYMBOLS[rand(255)],rand(0xFFFF0000,0xFF00FF00,0xFF0000FF,0xFFFFFF00,0xFFFF00FF,0xFF00FFFF,0xFFFFFFFF)]
	end
  end
  
  def draw()
	  #draw_frame params: (x,y,width,height,Z,style,color) styles: :double, :single, :solid, :heart
	  #draw_tiles params: (x,y,Z, symbol or array of symbols, :horizontal or :vertical, color)
	  # Z order: Background, Base, Foreground, Overlay
	  draw_frame(0,0,width/32,height/16,Background,:double,0xFFFFFFFF)
	  draw_frame(32,0,32,10,Base,:single,0xFFFFFFFF)
	  draw_frame(32,10,32,10,Foreground,:solid,0xFF0000FF)
	  draw_frame(32,20,32,10,Foreground,:heart,@color)
	  draw_tiles(33,11,Base,[:H,:e,:l,:l,:o,:space,:w,:o,:r,:l,:d],:horizontal,0xFFCCCCCC)
	  draw_tiles(33,31,Base,[:H,:e,:l,:l,:o,:space,:w,:o,:r,:l,:d],:vertical,0xFFFFFFFF)
	  draw_tiles(33,11,Background, [:fill100]*11,:horizontal,0x77FFFF00)
	  draw_tiles((mouse_x.to_i-1)/16,(mouse_y.to_i-1)/16,Overlay,:fill100,:horizontal,0x88FFFFFF)
	  @hash.each_pair do |key,value|
			draw_tiles(key[0],key[1],value[0],value[1],:horizontal,value[2])
			#value[0] = Z order, value[1] = symbol, value[2] = color
		end
		@hash.clear
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show