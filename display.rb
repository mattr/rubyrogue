# Display handles drawing of any kind. There are three ways to draw stuff.
# Text: It takes a string and converts it into array of symbols to be drawn.
# Buffer: The actual game state is stored in the buffer, which Display reads and draws stuff.
# GUI (frames, 'selectors' etc.) - context sensitive! 
# 
require 'gosu'
require 'handler'
require 'input'

module Interface
	class << self; attr_accessor :tileset end
	
	def draw_tiles(x,y,z_order,content,color=0xFFFFFFFF,direction=:horizontal)
		#expected argument must be either a Symbol or an Array of symbols
		# Draws either the one tile or a number of tiles into given direction
		if content.class==Symbol then
			@tileset[content].draw(x*16,y*16,z_order,1,1,color)
		elsif content.class==Array and direction==:horizontal then
			content.length.times {|i| @tileset[content[i]].draw((x+i)*16,y*16,z_order,1,1,color)}
		elsif content.class==Array and direction==:vertical then
			content.length.times {|j| @tileset[content[j]].draw(x*16,(y+j)*16,z_order,1,1,color)}
		else puts 'Error: parameter not Symbol or Array of Symbols'
		end
	end
	
	def draw_text(x,y,text,color=0xFFCCCCCC) # method for drawing strings and numbers
		string=text.to_s.split('').collect! {|s| s.intern}
		string.length.times {|i| @tileset[string[i]].draw((x+i)*16,y*16,1,1,1,color)}
	end
	
	def draw_buffer(x,y,width,height,buffer,off_x=0,off_y=0)
		#draw the array contents; use off_x and off_y to offset buffer coordinates (i.e. draw only a part of the buffer)
		height.times do |j|
			width.times do |i|
				draw_tiles(x+i,y+j,0,buffer[i+off_x][j+off_y][0],buffer[i+off_x][j+off_y][1])
			end
		end
	end
end

class Text
	attr_accessor :state, :content, :x, :y, :color
	include Drawable
	def initialize(x,y,content='',color=0xFFFFFFFF)
		@content=content
		@x=x
		@y=y
		@color=color
		@state=:enabled
		yield if block_given?
	end
		
	def draw
		if @state==:enabled then Interface::draw_text(@x,@y,@content,@color) end
	end
	
	def remove
		Drawable::remove(self)
	end
end

class Tile
	attr_accessor :state, :content, :x, :y, :z, :color, :direction
	include Drawable
	
	def initialize(x,y,z=0,content=:empty,color=0xFFFFFFFF,direction=:horizontal)
		@x=x
		@y=y
		@z=z
		@content=content
		@color=color
		@direction=direction
		@state=:enabled
	end
	
	def draw
		if @state==:enabled then Interface::draw_tiles(@x,@y,@z,@content,@color,@direction) end
	end
	
	def remove
		Drawable::remove(self)
	end
end

class Frame
	attr_accessor :state, :x, :y, :width, :height, :z, :color, :type, :tileset
	include Drawable
	# order: topleft corner, topright corner, bottomright corner, bottomleft corner, horizontal, vertical
	puts "FRAME_DOUBLE"
	FRAME_DOUBLE=[:table_topleft_double,:table_topright_double,:table_bottomright_double,:table_bottomleft_double,:table_horizontal_double,:table_vertical_double]
	FRAME_SINGLE=[:table_topleft_single,:table_topright_single, :table_bottomright_single,:table_bottomleft_single, :table_horizontal_single, :table_vertical_single]
	
	def initialize(x,y,width,height,z=0,color=0xFFFFFFFF,type=:single)
		@x=x
		@y=y
		@z=z
		@width=width
		@height=height
		@color=color
		@type=type
		@state=:enabled
		@tiles=FRAME_SINGLE
	end
	
	def draw
		if @state==:enabled then
			if type==:double then
				@tiles=FRAME_DOUBLE
			elsif type==:single then
				@tiles=FRAME_SINGLE
			else @tiles=[@type]*6
			end
			Interface::draw_tiles(@x,               @y,                @z,@tiles[0],                    @color) #topleft corner
			Interface::draw_tiles(@x+@width-1,@y,                @z,@tiles[1],                    @color) #topright corner
			Interface::draw_tiles(@x+@width-1,@y+@height-1,@z,@tiles[2],                    @color) #bottomright corner
			Interface::draw_tiles(@x,               @y+@height-1,@z,@tiles[3],                    @color) #bottomleft corner
			if @width>2 then Interface::draw_tiles(@x+1,           @y,                @z,[@tiles[4]]*(@width-2), @color,:horizontal) end #horizontal wall (upper)
			if @width>2 then Interface::draw_tiles(@x+1,           @y+@height-1,@z,[@tiles[4]]*(@width-2), @color,:horizontal) end #horizontal wall (lower)
			if @height>2 then Interface::draw_tiles(@x,               @y+1,            @z,[@tiles[5]]*(@height-2),@color,:vertical) end #vertical wall (left)
			if @height>2 then Interface::draw_tiles(@x+@width-1,@y+1,            @z,[@tiles[5]]*(@height-2),@color,:vertical) end #vertical wall (right)
		end
	end
	
	def remove
		Drawable::remove(self)
	end
end

class Camera
  attr_reader :x1, :x2, :y1, :x2, :x, :y, :width, :height # showing off aside, there's no reason to not make those actual instance vars
  
  def initialize(x, y, width, height)
    @x, @y, @width, @height = x, y, width, height
    @x1, @y1 = x-@width/2, y-@height/2
    @x2, @y2 = @x1+@width-1, @y1+@height-1
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
    @x1, @x2 = x-@width/2, @x1+@width-1
  end
  
  def height=(new_height)
    @height = new_height
    @y1, @y2 = y-@height/2, @y1+@height-1
  end
end

class Viewport
	attr_accessor :x, :y, :width,:height,:mode, :camera
	include Drawable
	include Updatable
	
	def initialize(screen_x,screen_y,width,height,camera=nil)
		
	end
end