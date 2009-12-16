require 'gosu'

# Handle keyboard input
class Input
  KEYS={
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
    :alt => [Gosu::KbLeftAlt],
    :ctrl => [Gosu::KbLeftControl],
    :shift => [Gosu::KbLeftShift],
    :plus => [Gosu::KbNumpadAdd],
    :divide => [Gosu::KbNumpadDivide],
    :multiply => [Gosu::KbNumpadMultiply],
    :minus => [Gosu::KbNumpadSubtract],
    :pagedown => [Gosu::KbPageDown],
    :pageup => [Gosu::KbPageUp],
    :enter => [Gosu::KbReturn],
    :right => [Gosu::KbRight],
    :alt => [Gosu::KbRightAlt],
    :ctrl => [Gosu::KbRightControl],
    :shift => [Gosu::KbRightShift],
    :space => [Gosu::KbSpace],
    :tab => [Gosu::KbTab],
    :up => [Gosu::KbUp],
    :click_left => [Gosu::MsLeft],
    :click_middle => [Gosu::MsMiddle],
    :click_right => [Gosu::MsRight],
    :wheel_down => [Gosu::MsWheelDown],
    :wheel_up => [Gosu::MsWheelUp],
  }
	
	def initialize
		@keys=Hash.new
	end
	
  def read(window)
    KEYS.each do |symbol, keys|
      is_pressed = keys.inject(false){|pressed, key| window.button_down?(key) or pressed}
      if is_pressed then
        @keys[symbol] ||= 0 # set to zero if it didn't exist, don't touch otherwise
        @keys[symbol] += 1
      else
        @keys.delete(symbol)
      end
    end
    return @keys
  end
end