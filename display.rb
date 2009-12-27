# Display handles drawing of any kind. There are three ways to draw stuff.
# Text: It takes a string and converts it into array of symbols to be drawn.
# Buffer: The actual game state is stored in the buffer,  which Display reads and draws stuff.
# GUI (frames,  'selectors' etc.) - context sensitive! 
# 
require 'gosu'
require 'handler'

module Interface
  class << self; attr_accessor :tileset end
  
  def draw_tiles(x, y, z_order, content, color=0xFFFFFFFF, direction=:horizontal)
    #expected argument must be either a Symbol or an Array of symbols
    # Draws either the one tile or a number of tiles into given direction
    if content.kind_of?(Symbol) then
      @tileset[content].draw(x*16, y*16, z_order, 1, 1, color)
    elsif content.kind_of?(Array) 
      if direction == :horizontal then
        content.length.times {|i| @tileset[content[i]].draw((x+i)*16, y*16, z_order, 1, 1, color)}
      else # if direction==:vertical then
        content.length.times {|j| @tileset[content[j]].draw(x*16, (y+j)*16, z_order, 1, 1, color)}
      end
    else
      raise "Error: parameter not Symbol or Array (#{$!})" # changed from 'Error: parameter not Symbol or Array of Symbols', as it doesn't really check what the elements of the array are. Also, changed puts to raise, since this is quite a show-stopping error
    end
  end
  
  def draw_text(x, y, text, color=0xFFCCCCCC) # method for drawing strings and numbers
    string = text.to_s.split('').collect! {|s| s.intern}
    string.length.times {|i| @tileset[string[i]].draw((x+i)*16, y*16, 1, 1, 1, color)}
  end
  
  def draw_map(x, y, width, height, map, map_x=0, map_y=0) #specially for drawing the game map; the map contains a visible symbol and a color
    horiz = [width, map[0].length+map_x].min #in case of drawing outside map bounds
    vert = [height, map.length+map_y].min
    vert.times do |j|
      horiz.times do |i|
        draw_tiles(x+i, y+j, 0, map[j+map_y][i+map_x][0], map[j+map_y][i+map_x][1])
      end
    end
  end
end

class Text
  attr_accessor :state, :content, :x, :y, :color
  include Drawable
  def initialize(x, y, content='', color=0xFFFFFFFF)
    @content, @x, @y, @color, @state = content, x, y, color, :enabled
    yield if block_given?
  end
    
  def draw
    if @state==:enabled then Interface::draw_text(@x, @y, @content, @color) end
  end
  
  def remove
    Drawable::remove(self)
  end
end

class Tile
  attr_accessor :state, :content, :x, :y, :z, :color, :direction
  include Drawable
  
  def initialize(x, y, z=0, content=:empty, color=0xFFFFFFFF, direction=:horizontal)
    @x, @y, @z, @content, @color, @direction, @state = x, y, z, content, color, direction, :enabled
  end
  
  def draw
    if @state == :enabled then Interface::draw_tiles(@x, @y, @z, @content, @color, @direction) end
  end
  
  def remove
    Drawable::remove(self)
  end
end

class Frame
  attr_accessor :state, :x, :y, :width, :height, :z, :color, :type, :tileset
  include Drawable
  # order: topleft corner,  topright corner,  bottomright corner,  bottomleft corner,  horizontal,  vertical
  FRAME_DOUBLE=[:table_topleft_double, :table_topright_double, :table_bottomright_double, :table_bottomleft_double, :table_horizontal_double, :table_vertical_double]
  FRAME_SINGLE=[:table_topleft_single, :table_topright_single,  :table_bottomright_single, :table_bottomleft_single, :table_horizontal_single, :table_vertical_single]
  
  def initialize(x, y, width, height, z=0, color=0xFFFFFFFF, type=:single)
    @x, @y, @z, @width, @height, @color, @type, @state, @tiles = x, y, z, width, height, color, type, :enabled, FRAME_SINGLE
  end
  
  def draw
    if @state==:enabled then
      if type==:double then
        @tiles=FRAME_DOUBLE
      elsif type==:single then
        @tiles=FRAME_SINGLE
      else
        @tiles=[@type]*6
      end
      Interface::draw_tiles(@x,          @y,           @z, @tiles[0], @color) #topleft corner
      Interface::draw_tiles(@x+@width-1, @y,           @z, @tiles[1], @color) #topright corner
      Interface::draw_tiles(@x+@width-1, @y+@height-1, @z, @tiles[2], @color) #bottomright corner
      Interface::draw_tiles(@x,          @y+@height-1, @z, @tiles[3], @color) #bottomleft corner
      
      Interface::draw_tiles(@x+1,        @y,           @z, [@tiles[4]]*(@width-2),  @color, :horizontal) if @width>2 #horizontal wall (upper)
      Interface::draw_tiles(@x+1,        @y+@height-1, @z, [@tiles[4]]*(@width-2),  @color, :horizontal) if @width>2 #horizontal wall (lower)
      Interface::draw_tiles(@x,          @y+1,         @z, [@tiles[5]]*(@height-2), @color, :vertical) if @height>2 #vertical wall (left)
      Interface::draw_tiles(@x+@width-1, @y+1,         @z, [@tiles[5]]*(@height-2), @color, :vertical) if @height>2 #vertical wall (right)
    end
  end
  
  def remove
    Drawable::remove(self)
  end
end

class Camera
  include Updatable
  attr_reader :x1, :x2, :y1, :x2, :x, :y, :width, :height, :view, :target, :active # showing off aside,  there's no reason to not make those actual instance vars
  
  def initialize(x,  y,  width,  height, map)
    @x, @y, @width, @height = x, y, width, height
    @x1, @y1 = x-@width/2, y-@height/2
    @x2, @y2 = @x1+@width-1, @y1+@height-1
    @target=map # what camera is looking at
    @view=Array.new(@height){Array.new(@width,[:' ',0x00000000])}#what the camera sees
    @active=true
    record()
  end
  
  def record()
    if @active then
      @height.times do |j|
        @width.times do |i|
          @view[j][i]=@target[(j+@y1) % @target.length][(i+@x1) % @target[0].length]
          end
      end
    end
  end
  
  def x=(new_x)
    @x1 += new_x-@x
    @x2 += new_x-@x
    @x = new_x
  end
  
  def y=(new_y)
    @y1 += new_y-@y
    @y2 += new_y-@y
    @y = new_y
  end

  def width=(new_width)
    @width = new_width
    @x1,  @x2 = x-@width/2,  @x1+@width-1
  end
  
  def height=(new_height)
    @height = new_height
    @y1,  @y2 = y-@height/2,  @y1+@height-1
  end
  
  def update
    record()
  end
  
  def remove
    Updatable::remove(self)
  end
end

class Viewport
  attr_accessor :x, :y, :width, :height, :mode,  :camera
  include Drawable
  
  def initialize(screen_x, screen_y, camera) #needs camera to work with
    @x=screen_x
    @y=screen_y
    @camera=camera
    @width=@camera.width
    @height=@camera.height
  end
  
  def draw
    if @camera.active then
      Interface::draw_map(@x,@y,@width,@height,@camera.view)
    end
  end
  
  def remove
    Drawable::remove(self)
  end
end