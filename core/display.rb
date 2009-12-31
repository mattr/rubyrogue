# Display handles drawing of any kind. There are three ways to draw stuff.
# Text: It takes a string and converts it into array of symbols to be drawn.
# Buffer: The actual game state is stored in the buffer,  which Display reads and draws stuff.
# GUI (frames,  'selectors' etc.) - context sensitive! 
# 
require 'gosu'
require './core/handler'
require './core/misc'

class Tileset < Gosu::Image
  def Tileset.new(window, filename="./images/Cooz_16x16.png", symbols = SYMBOLS, alternate = ALTERNATE_SYMBOLS) # filenames are case sensitive on some OSes
    tileset_array = Tileset.load_tiles(window, filename, 16, 16, 0)
    hash = Hash[*symbols.zip(tileset_array).flatten]
    alternate.each{|key, value| hash[key] = hash[value]}
    return hash
  end
end

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
  attr_accessor :x1, :x2, :y1, :x2, :x, :y, :width, :height, :view, :target, :active, :tilable # showing off aside,  there's no reason to not make those actual instance vars
  
  def initialize(x,  y,  width,  height, instance, tilable=[true, true])
    @x, @y, @width, @height, @tilable = x, y, width, height, tilable
    @x1, @y1 = x-@width/2, y-@height/2
    @x2, @y2 = @x1+@width-1, @y1+@height-1
    @target=instance # what camera is looking at
    @view=Array.new(@height){Array.new(@width,[:' ',0x00000000])}#what the camera sees
    @active=true
    record() if @active
  end
  
  def record()
    @height.times do |j|
      @width.times do |i|
          x=i+@x1
          y=j+@y1
          if @tilable[0] and @tilable[1] then #wrap both ways
            @view[j][i]=@target.map[y % @target.height][x % @target.width]
          elsif @tilable[0] and not @tilable[1] then #wrap horizontally only
            if y>=0 and y<@target.height then 
              @view[j][i]=@target.map[y][x % @target.width] 
            else
              @view[j][i]=[:' ',0x00000000] #empty square
            end
          elsif not @tilable[0] and @tilable[1] then # wrap vertically only
            if x>=0 and x<@target.width then
              @view[j][i]=@target.map[y % @target.height][x]
            else
              @view[j][i]=[:' ',0x00000000]
            end
          else #no wrapping at all
            if (x>=0 and x<@target.width) and (y>=0 and y<@target.height) then
              @view[j][i]=@target.map[y][x]
            else
              @view[j][i]=[:' ',0x00000000]
            end
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
    record() if @active
  end
  
  def remove
    Updatable::remove(self)
  end
end

class Viewport
  attr_accessor :x, :y, :width, :height, :mode,  :camera
  include Drawable
  
  def initialize(screen_x, screen_y, camera) #needs camera to work with
    @x, @y, @camera = screen_x, screen_y, camera
    @width, @height = @camera.width, @camera.height
  end
  
  def draw
    if @camera.active then
      Interface::draw_map(@x, @y, @width, @height, @camera.view)
    end
  end
  
  def remove
    Drawable::remove(self)
  end
end