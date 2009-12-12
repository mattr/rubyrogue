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
    @benchmark=Gosu::milliseconds()
  end
  
  def update()
  end
  
  def draw()
	  #draw_frame params: (x,y,width,height,Z, color, style) styles: :double, :single, :solid, :heart
	  #draw_tiles params: (x,y,Z, symbol or array of symbols, color, :horizontal or :vertical)
	  # Z order: Background, Base, Foreground, Overlay
	  draw_tiles(0,0,Base,"Keyboard Test: ", 0xFFFFFFCC, :horizontal)
	  string="0123456789012345678901234567890123456789012345678901234567890124"
	  start = Gosu::milliseconds()
	  47.times do |j| 
		  draw_tiles(0,j+1,Base,string)
		 # string.length.times do |i| 
		#	draw_tiles(i,j+1,Base,string[i],Gosu::Color.new((255*(1-i.to_f/(string.length-1))).to_i, (255*(i.to_f/(string.length-1))).to_i, 0))
		end
	delta = Gosu::milliseconds()-start
	self.caption=delta
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show