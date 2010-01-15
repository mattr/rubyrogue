#various GUI elements

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
        Display.blit(@x+i,@y,LAYER_TEXT,@content[i].intern,color)
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

class Button # a simple button. Button.new(x,y,'text' or :symbol) {action}
  include Drawable
  attr_accessor :x, :y, :text, :action, :next, :prev
  
  def initialize(x, y, text, toggle=false, &block)
    @focus = false
    @enabled = true
    @action = block
    @x,@y, @text= x, y, text
    @content_type = (@text.class==Symbol) ? :symbol : :text
    @toggle_button = toggle
    @toggled = false
    @next = nil
    @prev = nil
  end
  
  def selected?
    return @focus
  end
  
  def select
    @focus = true
  end
  
  def unselect
    @focus = false
  end
  
  def toggled?
    return @toggled
  end
  
  def enabled?
    return @enabled
  end
    
  def enable
    @enabled = true
  end
  
  def disable
    @enabled = false
  end
  
  def action
    if @enabled then
      if @toggle_button then
        @toggled = @toggled ? false : true
        return @action.call
      else
        return @action.call
      end
    end
  end
  
  def next_button
    if @next then
      @focus = false
      if @next.enabled? then
        @next.select
        return @next
      else
        @next.next_button
      end
    end
  end
  
  def prev_button
    if @prev then
      @focus = false
      if @prev.enabled? then
        @prev.select
        return @prev
      else
        @prev.prev_button
      end
    end
  end
  
  def draw
    if @enabled then
      if @toggle_button then
        color = @focus ? (@toggled ? BUTTON_TOGGLE_ON_HIGHLIGHTED : BUTTON_TOGGLE_OFF_HIGHLIGHTED) : (@toggled ? BUTTON_TOGGLE_ON : BUTTON_TOGGLE_OFF)
      else
        color = @focus ? BUTTON_HIGHLIGHTED : BUTTON_DEFAULT 
      end
    else
      color = BUTTON_DISABLED
    end
    
    if @content_type == :text then
      Display.blit_text(@x,@y,LAYER_TEXT,@text, color)
    else
      Display.blit(@x,@y,LAYER_TEXT,@text, color)
    end
  end
  
  def remove
    Drawable::remove(self)
  end  
end