# For drawing of game map or overhead view

class Camera # read the map around given coordinates 
  include Updatable
  attr_accessor :x1, :x2, :y1, :x2, :x, :y, :width, :height, :view, :target, :active, :tilable # showing off aside,  there's no reason to not make those actual instance vars
  EMPTY_TILE = [:' ',0x00000000]
  def initialize(x,  y,  width,  height, instance, tilable=[true, true])
    @x, @y, @width, @height, @tilable = x, y, width, height, tilable
    @x1, @y1 = x-@width/2, y-@height/2
    @x2, @y2 = @x1+@width-1, @y1+@height-1
    @target=instance # what camera is looking at
    @view=[EMPTY_TILE*@width]*@height#what the camera sees
    @active=true
    record()
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
              @view[j][i]=EMPTY_TILE #empty square
            end
          elsif not @tilable[0] and @tilable[1] then # wrap vertically only
            if x>=0 and x<@target.width then
              @view[j][i]=@target.map[y % @target.height][x]
            else
              @view[j][i]=EMPTY_TILE
            end
          else #no wrapping at all
            if (x>=0 and x<@target.width) and (y>=0 and y<@target.height) then
              @view[j][i]=@target.map[y][x]
            else
              @view[j][i]=EMPTY_TILE
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
      @height.times do |j|
        @width.times do |i|
          Display.blit(@x+i, @y+j, 0, @camera.view[j][i][0], @camera.view[j][i][1])
        end
      end
    end
  end
  
  def remove
    Drawable::remove(self)
  end
end