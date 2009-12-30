require 'gosu'
require 'display'
require 'handler'
include Interface

module Keys # LOCAL - use these methods instead of ones supplied by Input!
  def self.triggered?(instance, key)
    return (instance.keys.include?(key) and Input.triggered?(key)) # return is optional here, but I prefer to have it explicitly in the code
  end
  
  def self.is_down?(instance, key)
    return (instance.keys.include?(key) and Input.is_down?(key))
  end
  
  def self.ready?(instance, key)
    return (instance.keys.include?(key) and Input.ready?(key))
  end
  
  def self.released?(instance, key) # be careful using this one, as it can be affected on global scale!
    return Input.released?(key)
  end

  def self.life(instance,key)
    return instance.keys.include?(key) ? Input.life(key) : nil
  end
end

# This class is responsible for reading pressed keys and tracking them
module Input # GLOBAL - do not use if not absolutely necessary!
  class << self; attr_accessor :keys end
  DELAY = 150 # milliseconds
  ALL_KEYS = {
    :'0' => [Gosu::Kb0, Gosu::KbNumpad0],
    :'1' => [Gosu::Kb1, Gosu::KbNumpad1],
    :'2' => [Gosu::Kb2, Gosu::KbNumpad2],
    :'3' => [Gosu::Kb3, Gosu::KbNumpad3],
    :'4' => [Gosu::Kb4, Gosu::KbNumpad4],
    :'5' => [Gosu::Kb5, Gosu::KbNumpad5],
    :'6' => [Gosu::Kb6, Gosu::KbNumpad5],
    :'7' => [Gosu::Kb7, Gosu::KbNumpad6],
    :'8' => [Gosu::Kb8, Gosu::KbNumpad7],
    :'9' => [Gosu::Kb9, Gosu::KbNumpad8],
    :A => [Gosu::KbA],
    :B => [Gosu::KbB],
    :C => [Gosu::KbC],
    :D => [Gosu::KbD],
    :E => [Gosu::KbE],
    :F => [Gosu::KbF],
    :G => [Gosu::KbG],
    :H => [Gosu::KbH],
    :I => [Gosu::KbI],
    :J => [Gosu::KbJ],
    :K => [Gosu::KbK],
    :L => [Gosu::KbL],
    :M => [Gosu::KbM],
    :N => [Gosu::KbN],
    :O => [Gosu::KbO],
    :P => [Gosu::KbP],
    :Q => [Gosu::KbQ],
    :R => [Gosu::KbR],
    :S => [Gosu::KbS],
    :T => [Gosu::KbT],
    :U => [Gosu::KbU],
    :V => [Gosu::KbV],
    :W => [Gosu::KbW],
    :X => [Gosu::KbX],
    :Y => [Gosu::KbY],
    :Z => [Gosu::KbZ],
    :backspace => [Gosu::KbBackspace],
    :delete => [Gosu::KbDelete],
    :down => [Gosu::KbDown],
    :end => [Gosu::KbEnd],
    :enter => [Gosu::KbEnter],
    :esc => [Gosu::KbEscape],
    :F1 => [Gosu::KbF1],
    :F10 => [Gosu::KbF10],
    :F11 => [Gosu::KbF11],
    :F12 => [Gosu::KbF12],
    :F2 => [Gosu::KbF2],
    :F3 => [Gosu::KbF3],
    :F4 => [Gosu::KbF4],
    :F5 => [Gosu::KbF5],
    :F6 => [Gosu::KbF6],
    :F7 => [Gosu::KbF7],
    :F8 => [Gosu::KbF8],
    :F9 => [Gosu::KbF9],
    :home => [Gosu::KbHome],
    :ins => [Gosu::KbInsert],
    :left => [Gosu::KbLeft],
    :'+' => [Gosu::KbNumpadAdd,13],
    :'/' => [Gosu::KbNumpadDivide],
    :'*' => [Gosu::KbNumpadMultiply],
    :'-' => [Gosu::KbNumpadSubtract],
    :pagedown => [Gosu::KbPageDown],
    :pageup => [Gosu::KbPageUp],
    :enter => [Gosu::KbReturn],
    :right => [Gosu::KbRight],
    :' ' => [Gosu::KbSpace],
    :tab => [Gosu::KbTab],
    :up => [Gosu::KbUp],
    :click_left => [Gosu::MsLeft],
    :click_middle => [Gosu::MsMiddle],
    :click_right => [Gosu::MsRight],
    :wheel_down => [Gosu::MsWheelDown],
    :wheel_up => [Gosu::MsWheelUp],
    :alt => [Gosu::KbRightAlt, Gosu::KbLeftAlt],
    :ctrl => [Gosu::KbRightControl, Gosu::KbLeftControl],
    :shift => [Gosu::KbRightShift, Gosu::KbLeftShift]
  }
  ALPHABET = ('A'..'Z').to_a.collect{|s| s.intern}
  NUMBERS = (0..9).to_a.collect{|n| n.to_s.intern}
  ALPHANUMERIC = ALPHABET+NUMBERS+[:' ']
  ARROWS = [:left,:right,:up,:down]
  PAGE_CONTROLS = [:home,:end,:pageup,:pagedown]
  FUNCTION = [:F1,:F2,:F3,:F4,:F5,:F6,:F7,:F8,:F9,:F10,:F11,:F12]
  @keys = {} #store pressed and released keys like this: :key => value or :released
  # where value means the number of ticks it's been pressed for and :released means the key's been released
  
  # @keys hash is populated with active keys, which can have one of those states:
  # : (the first tick it is pressed down), :down (
  def self.read_keys(window)
    ALL_KEYS.each do |symbol, keys| #iterate through all known symbols
      is_pressed = keys.inject(false) {|pressed, key| window.button_down?(key) or pressed} #there can be multiple keys for each symbol
      if is_pressed then # the key is being pressed
        if @keys.key?(symbol) and not @keys[symbol]==:released then
          @keys[symbol] += 1 #it already is being tracked, so just increment
        else # not tracked, add it
          @keys[symbol] = 0
        end
      else # the key is not pressed (released previous tick or not pressed at all)
        if @keys.key?(symbol) then # we are only concerned with keys that were still active last tick
          if not @keys[symbol] == :released then
            @keys[symbol] = :released #set the key as released
          else
            @keys.delete(symbol) #the key has no business being in the hash anymore
          end
        end
      end
    end
    return @keys.keys
  end

  def self.released?(key) # only return true if the key was pressed last tick and is not pressed anymore
    return (@keys.include?(key) and @keys[key] == :released )
  end
  
  def self.is_down?(key) #returns true if the key is pressed, regardless of DELAY
    return (@keys.include?(key) and not @keys[key] == :released)
  end
  
  def self.triggered?(key) #only the first keypress is counted
    return (@keys.include?(key) and @keys[key] == 0)
  end
  
  def self.ready?(key) #continuous keypress, trigger in intervals based on DELAY
    return (is_down?(key) and @keys[key] % (60*DELAY/1000) == 0)
  end
  
  def self.life(key) #returns the duration key's pressed in ticks
    return is_down?(key) ? @keys[key] : false
  end
end

  # This class handles entering text; the object would remain until either of control keys (esc, enter) is pressed, then closes and returns the value)
class TextInput
  attr_accessor :keys
  include Updatable
  include Drawable
  include Inputable
  KEYS=Input::ALPHANUMERIC+[:left,:right,:backspace,:delete,:enter, :esc, :ins, :home, :end, :shift]
  def initialize(instance)
    @default_text, @instance, @cursor, @mode, @keys = instance.content.dup, instance, instance.content.length, :insert, []
    # mode is :insert or :replace, based on Insert key, insert by default
  end
  
  def update
    if Keys.triggered?(self, :esc) then 
      @instance.content=@default_text
      self.remove
    elsif Keys.triggered?(self, :enter) then 
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
        if (Input::NUMBERS.include?(key) or key == :' ') and Input.ready?(key) then
          if @mode==:insert then #insert a letter and then increment the cursor
            @instance.content.insert(@cursor, key.to_s)
            @cursor += 1
          else   #replace the current letter
            @instance.content[@cursor] = key.to_s
          end
        elsif Input::ALPHABET.include?(key) and Input.ready?(key) then
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
  
  def draw
    Interface::draw_tiles(@instance.x+@cursor, @instance.y, 0, :border, 0x88FFFF33)
  end
  
  def remove
    Updatable::remove(self)
    Drawable::remove(self)
    Inputable::remove(self)
  end
end