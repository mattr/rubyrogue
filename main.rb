require 'gosu'
#require 'keyboard'
#require 'display'
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
  end
  
  def update()

  end
  
  def draw()    
    16.times {|j| 16.times {|i| @tileset[Tileset::SYMBOLS[i+j*16]].draw(i*16,j*16,0)}}
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show