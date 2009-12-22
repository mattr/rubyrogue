require 'gosu'
require 'display'
require 'handler'
include Interface

# This class is responsible for reading pressed keys and tracking them
module Input
	class << self; attr_accessor :active, :triggered end
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
  ALPHABET=('A'..'Z').to_a.collect{|s| s.intern}
  NUMBERS=(0..9).to_a.collect{|n| n.to_s.intern}
  ALPHANUMERIC=ALPHABET+NUMBERS+[:' ']
  ARROWS=[:left,:right,:up,:down]
  PAGE_CONTROLS=[:home,:end,:pageup,:pagedown]
  FUNCTION=[:F1,:F2,:F3,:F4,:F5,:F6,:F7,:F8,:F9,:F10,:F11,:F12]
    @active= {}
    @triggered=[]
	
	def self.read(window)
	@triggered.clear
	ALL_KEYS.each do |symbol, keys|
		is_pressed = keys.inject(false){|pressed, key| window.button_down?(key) or pressed}
		if is_pressed then
			if @active[symbol] then
				@active[symbol] += 1
			else
				@active[symbol] = 0
				@triggered << symbol
			end
		else
			@active.delete(symbol)
		end
	end
	return [@active,@triggered]
	end

	def self.triggered?(key)
		@triggered.include?(key)
	end
	
	def self.is_pressed?(key)
		if (@active.include?(key) and @active[key]>=60*DELAY/1000) or @triggered.include?(key) then
			@active[key]=0
			return true
		else
			return false
		end
	end
end

	# This class handles entering text; the object would remain until either of control keys (esc, enter) is pressed, then closes and returns the value)
class TextInput
	attr_accessor :content, :x, :y, :limit, :triggers, :controls
	include Updatable
	include Drawable
	include Inputable
	TRIGGERS=[:enter, :esc, :ins, :home, :end] #single keypress
	CONTROLS=Input::ALPHANUMERIC+[:left,:right,:backspace,:delete] #continuous keypress
	def initialize(x,y,text='',length=64)
		@default=text
		@x = x
		@y = y
		@content=text.split('').collect{|s| s.intern}
		@limit=length
		@cursor=text.length
		@mode=:insert # :insert or :replace, based on Insert key, insert by default
		@triggers=[]
		@controls={}
	end
	
	def update
		#below code is deprecated
		#~ if Input.triggered?(:esc) then return [:cancel,@default]
		#~ elsif Input.triggered?(:enter) then return [:ok,@content.join]
		#~ else 
			#~ if Input.is_pressed?(:left) and (@cursor)>0 then @cursor-=1
			#~ elsif Input.is_pressed?(:right) and @cursor<@content.length and @cursor<@limit then @cursor+=1
			#~ elsif Input.is_pressed?(:delete) then @content.delete_at(@cursor)
			#~ elsif Input.is_pressed?(:backspace) and not @content.empty? then 
				#~ @content.delete_at(@cursor-1)
				#~ if @cursor>0 then @cursor-=1 end
			#~ else
				#~ Input::ALPHANUMERIC.each {|letter| 
					#~ if Input.is_pressed?(letter) then 
						#~ if @cursor<@content.length and @content.length<@limit then 
							#~ if Input::ALPHABET.include?(letter) then
								#~ if Input.active.include?(:shift) then @content.insert(@cursor,letter)
								#~ else @content.insert(@cursor,letter.to_s.downcase.intern) end
							#~ else
								#~ @content.insert(@cursor,letter)
								#~ @cursor+=1
							#~ end
						#~ elsif @content.length<@limit then 
							#~ if Input::ALPHABET.include?(letter) then
								#~ if Input.active.include?(:shift) then @content << letter
								#~ else @content << letter.to_s.downcase.intern end
							#~ else
								#~ @content << letter
							#~ end
							#~ @cursor+=1
						#~ else
							#~ if Input::ALPHABET.include?(letter) then
								#~ if Input.active.include?(:shift) then @content[@cursor]=letter
								#~ else @content[@cursor]=letter.to_s.downcase.intern end
							#~ else @content[@cursor]=letter
							#~ end
						#~ end
					#~ end }
			#~ end
			#~ return [:pending,@content.join]
		#~ end		
	end
	
	def draw
		#also deprecated
		#~ if (not @content.empty?) then Interface::draw_tiles(@x,@y,0,@content) end
		#~ if (Gosu::milliseconds()%500>100) then Interface::draw_tiles(@x+@cursor,@y,1,:fill100,0x88FFFF00) end
	end
	
	def remove
		Updatable::remove(self)
		Drawable::remove(self)
		Inputable::remove(self)
	end
end