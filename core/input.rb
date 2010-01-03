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