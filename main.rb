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
    super(800,600,0)
    self.caption="Generic title"
    @tileset=Tileset.new(self)
    @interface=Interface.new(@tileset)
  end
  
  def update()

  end
  
  def draw()
	  @interface.frame(0,0,width/16,height/16,:solid,0xFF888888) #this draws a neat border along screen edges
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show