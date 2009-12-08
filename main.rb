require 'gosu'
require 'keyboard'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()

class GameWindow < Gosu::Window
# advanced initialization, not really needed now
#  def initialize(ini)
#    x=ini['Display']['DisplayX']
#    y=ini['Display']['DisplayY']
#    z=ini['Display']['Fullscreen']
#    super(x.to_i,y.to_i,z.to_i)
  def initialize
    super(1024,768,0)
    self.caption="Generic title"
    @tileset=Tileset.new(self)
    Interface.set_tileset(@tileset)
    @color=Gosu::Color.new(0xFFFFFFFF)
  end
  
  def update()
	@timer=Gosu::milliseconds()/5
	@color=Gosu::Color.new(255,0,@timer%255,0)

  end
  
  def draw()
	  Interface.draw_frame(0,0,width/32,height/16,:double,0xFF00FFFF)
	  Interface.draw_frame(32,0,32,10,:single,0xFFFFFFFF)
	  Interface.draw_frame(32,10,32,10,:solid,0xFF0000FF)
	  Interface.draw_frame(32,20,32,10,:heart,0xFFFF0000)
	  Interface.draw_tiles(33,11,[:H,:e,:l,:l,:o,:space,:w,:o,:r,:l,:d],:horizontal,0xFFCCCCCC)
	  Interface.draw_tiles(33,31,[:H,:e,:l,:l,:o,:space,:w,:o,:r,:l,:d],:vertical,@color)
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show