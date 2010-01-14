# Viewport is used as a middle man between the game world data and display engine.
# Read the game data, convert it into displayable format and cache it for the drawing code to read.
# NOT YET COMPLETED
require 'handler'

class Viewport
  include Updatable
  
  MODES = [
  :normal,
  :elevation,
  :temperature,
  :rainfall
  
  ]
  def initialize(source, width, height, off_x, off_y, mode=:normal)
    @source, @width, @height, @off_x, @off_y, @mode = source, width, height, off_x, off_y, normal
    @buffer=Array.new(@height){Array.new(@width){nil}}
    
    
  end
  
  def [](x,y)
    return @buffer[y][x]
  end
  
  def get_value(x,y)
    return @source[y][x]
  end
  
  def update
    
  end
  
  def remove
    Updatable::remove(self)
  end
end