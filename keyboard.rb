require 'gosu'

# Handle keyboard input
class Input
	KEYS={ # issue: duplicate values seem to exclude other
	Gosu::Kb0 => :'0',
	Gosu::Kb1 => :'1',
	Gosu::Kb2 => :'2',
	Gosu::Kb3 => :'3',
	Gosu::Kb4 => :'4',
	Gosu::Kb5 => :'5',
	Gosu::Kb6 => :'6',
	Gosu::Kb7 => :'7',
	Gosu::Kb8 => :'8',
	Gosu::Kb9 => :'9',
	Gosu::KbA => :A,
	Gosu::KbB => :B,
	Gosu::KbC => :C,
	Gosu::KbD => :D,
	Gosu::KbE =>:E,
	Gosu::KbF => :F,
	Gosu::KbG => :G,
	Gosu::KbH => :H,
	Gosu::KbI => :I,
	Gosu::KbJ => :J,
	Gosu::KbK => :K,
	Gosu::KbL => :L,
	Gosu::KbM => :M,
	Gosu::KbN => :N,
	Gosu::KbO => :O,
	Gosu::KbP => :P,
	Gosu::KbQ => :Q,
	Gosu::KbR => :R,
	Gosu::KbS =>:S,
	Gosu::KbT => :T,
	Gosu::KbU => :U,
	Gosu::KbV => :V,
	Gosu::KbW => :W,
	Gosu::KbX => :X,
	Gosu::KbY => :Y,
	Gosu::KbZ => :Z,
	Gosu::KbBackspace => :backspace,
	Gosu::KbDelete => :delete,
	Gosu::KbDown => :down,
	Gosu::KbEnd => :end,
	Gosu::KbEnter => :enter,
	Gosu::KbEscape => :esc,
	Gosu::KbF1 => :F1,
	Gosu::KbF10 => :F10,
	Gosu::KbF11 => :F11,
	Gosu::KbF12 => :F12,
	Gosu::KbF2 => :F2,
	Gosu::KbF3 => :F3,
	Gosu::KbF4 => :F4,
	Gosu::KbF5 => :F5,
	Gosu::KbF6 => :F6,
	Gosu::KbF7 => :F7,
	Gosu::KbF8 => :F8,
	Gosu::KbF9 => :F9,
	Gosu::KbHome => :home,
	Gosu::KbInsert => :ins,
	Gosu::KbLeft => :left,
	Gosu::KbLeftAlt => :alt,
	Gosu::KbLeftControl => :ctrl,
	Gosu::KbLeftShift => :shift,
	Gosu::KbNumpad0 => :'0',
	Gosu::KbNumpad1 => :'1',
	Gosu::KbNumpad2 => :'2',
	Gosu::KbNumpad3 => :'3',
	Gosu::KbNumpad4 => :'4',
	Gosu::KbNumpad5 => :'5',
	Gosu::KbNumpad6 => :'6',
	Gosu::KbNumpad7 => :'7',
	Gosu::KbNumpad8 => :'8',
	Gosu::KbNumpad9 => :'9',
	Gosu::KbNumpadAdd => :plus,
	Gosu::KbNumpadDivide => :divide,
	Gosu::KbNumpadMultiply => :multiply,
	Gosu::KbNumpadSubtract => :minus,
	Gosu::KbPageDown => :pagedown,
	Gosu::KbPageUp => :pageup ,
#	Gosu::KbPause => :pause ,  #this gives error (uninitialized constant)
	Gosu::KbReturn => :enter,
	Gosu::KbRight => :right,
	Gosu::KbRightAlt => :alt,
	Gosu::KbRightControl => :ctrl,
	Gosu::KbRightShift => :shift,
	Gosu::KbSpace => :space,
	Gosu::KbTab => :tab,
	Gosu::KbUp => :up,
	Gosu::MsLeft => :click_left,
	Gosu::MsMiddle  => :click_middle,
	Gosu::MsRight => :click_right,
	Gosu::MsWheelDown => :wheel_down,
	Gosu::MsWheelUp => :wheel_up
	}
	
	def initialize
		@keys=Hash.new
	end
	
	def read(window)
		KEYS.each do |key,symbol|
			if window.button_down?(key) then 
				if @keys.key?(symbol) then @keys[symbol]+=1
				else @keys[symbol]=1 end
			else @keys.delete(symbol) end
		end
		return @keys
	end	
end