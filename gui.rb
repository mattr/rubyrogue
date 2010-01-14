#various GUI bits, DEPRECATED

class Text #draw text. Text.new(x,y,string,color)
  attr_accessor :state, :content, :x, :y, :color
  include Drawable
  def initialize(x, y, content='', color=0xFFFFFFFF)
    @content, @x, @y, @color, @state = content, x, y, color, :enabled
    yield if block_given?
  end
    
  def draw
    if @state==:enabled then
      @content.length.times do |i|
        Display.blit(@x+i,@y,1,@content[i].intern,color)
      end
    end
  end
  
  def remove
    Drawable::remove(self)
  end
end

class TextInput #handle text input  TextInput.new(Text _instance)
  attr_accessor :keys
  include Updatable
  include Drawable
  include Inputable
  
  KEYS = ALPHANUMERIC + [:enter, :left, :right, :esc, :end, :home, :backspace, :ins, :delete, :shift]
    
  
  def initialize(instance) #usage: var=TextInput.new(text) where text is the Text instance
    @default_text, @instance, @cursor, @mode, @keys = instance.content.dup, instance, instance.content.length, :insert, []
    # mode is :insert or :replace, based on Insert key, insert by default
    @orig_color=@instance.color
    @instance.color=0xFF00FFFF
  end
  
  def update
    if Keys.triggered?(self, :esc) then 
      @instance.content=@default_text
      @instance.color=@orig_color
      self.remove
    elsif Keys.triggered?(self, :enter) then 
      @instance.color=@orig_color
      self.remove
    elsif Keys.triggered?(self, :ins) then
      @mode = (@mode == :insert) ? :replace : :insert
    elsif Keys.triggered?(self, :home) then
      @cursor = 0
    elsif Keys.triggered?(self, :end) then
      @cursor = @instance.content.length
      #the above are triggers, only single keypresses; below can be continuous
    else
      # left and right cursor stuff
      @cursor -= 1 if Keys.ready?(self, :left) and @cursor>0
      @cursor += 1 if Keys.ready?(self, :right) and @cursor<@instance.content.length
      @instance.content[@cursor] = '' if Keys.ready?(self, :delete) and @cursor<@instance.content.length
      if Keys.ready?(self, :backspace) and @cursor>0 then
        @instance.content[@cursor-1] = ''
        @cursor -= 1 
      end
      #now we get to actually type!
      @keys.each do |key|
        if (NUMBERS.include?(key) or key == :' ') and Input.ready?(key) then
          if @mode==:insert then #insert a letter and then increment the cursor
            @instance.content.insert(@cursor, key.to_s)
            @cursor += 1
          else   #replace the current letter
            @instance.content[@cursor] = key.to_s
          end
        elsif ALPHABET.include?(key) and Input.ready?(key) then
          if @mode == :insert then
            if Keys.is_down?(self, :shift) then
              @instance.content.insert(@cursor, key.to_s)
            else
              @instance.content.insert(@cursor, key.to_s.downcase)
            end
            @cursor+=1
          else
            if Keys.is_down?(self, :shift) then
              @instance.content[@cursor] = key.to_s
            else
              @instance.content[@cursor] = key.to_s.downcase
            end
          end
        else #do nothing?
        end
      end
    end
    @cursor = @instance.content.length if @cursor > @instance.content.length
  end
  
  def draw # cursor
    Display.blit(@instance.x+@cursor, @instance.y, 0, :border, 0x88FFFF33)
  end
  
  def remove
    Updatable::remove(self)
    Drawable::remove(self)
    Inputable::remove(self)
  end
end

class Frame #simply draw a frame. Frame.new(x,y,width,height,z,color,symbol)
  attr_accessor :state, :x, :y, :width, :height, :z, :color, :type, :tileset
  include Drawable
  def initialize(x, y, width, height, z=0, color=0xFFFFFFFF, type=:single)
    @x, @y, @z, @width, @height, @color, @type, @tiles = x, y, z, width, height, color, type, FRAME_SINGLE
  end
  
  def draw
      if type==:double then
        @tiles=FRAME_DOUBLE
      elsif type==:single then
        @tiles=FRAME_SINGLE
      else
        @tiles=[@type]*6
      end
      Display.blit(@x,          @y,           @z, @tiles[0], @color) #topleft corner
      Display.blit(@x+@width-1, @y,           @z, @tiles[1], @color) #topright corner
      Display.blit(@x+@width-1, @y+@height-1, @z, @tiles[2], @color) #bottomright corner
      Display.blit(@x,          @y+@height-1, @z, @tiles[3], @color) #bottomleft corner
      
      (@width-2).times do |i|
        Display.blit(@x+i+1,        @y,           @z, @tiles[4],  @color) if @width>2 #horizontal wall (upper)
        Display.blit(@x+i+1,        @y+@height-1, @z, @tiles[4],  @color) if @width>2 #horizontal wall (lower)
      end
      (@height-2).times do |j|
        Display.blit(@x,          @y+j+1,         @z, @tiles[5], @color) if @height>2 #vertical wall (left)
        Display.blit(@x+@width-1, @y+j+1,         @z, @tiles[5], @color) if @height>2 #vertical wall (right)
      end
  end
  
  def remove
    Drawable::remove(self)
  end
end

class View # draw map (world, region, local) - Viewport.new(x,y,width,height,map,offset_x,offset_y,tilable_x,tilable_y)
  include Drawable
  attr_accessor :x, :y, :width, :height, :offset_x, :offset_y
  
  def initialize(x,y,width,height,map,offset_x=0,offset_y=0,tilable_x=false,tilable_y=false)
    @x,@y,@width,@height,@map,@offset_x,@offset_y,@tile_x,@tile_y=x,y,width,height,map,offset_x,offset_y,tilable_x,tilable_y
  end
  
  def draw
    Display.blit_map(@x,@y,@width,@height,@map,@offset_x,@offset_y,@tile_x,@tile_y)
  end
  
  def remove
    Drawable::remove(self)
  end
end