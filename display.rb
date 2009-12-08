# Display handles drawing of any kind. There are three ways to draw stuff.
# Text: It takes a string and converts it into array of symbols to be drawn.
# Buffer: The actual game state is stored in the buffer, which Display reads and draws stuff.
# GUI (frames, 'selectors' etc.) - context sensitive!
# 
require 'gosu'

class Interface
	# draw a rectangular frame
	def frame(x,y,width,height,type=:double,color=0xFFFFFFFF)
		case type
			when :double then
				tiles={:topleft => :table_topleft_double, :topright => :table_topright_double, :bottomright => :table_bottomright_double, :bottomleft => :table_bottomleft_double, :horizontal => :table_horizontal_double, :vertical => :table_vertical_double}
			when :single then
				tiles={:topleft => :table_topleft_single, :topright => :table_topright_single, :bottomright => :table_bottomright_single, :bottomleft => :table_bottomleft_single, :horizontal => :table_horizontal_single, :vertical => :table_vertical_single} 
			when :solid then 
				tiles={:topleft => :fill100, :topright => :fill100, :bottomright => :fill100, :bottomleft => :fill100, :horizontal => :fill100, :vertical => :fill100} 
		end
		@tileset[tiles[:topleft]].draw(x*16,y*16,0,1,1,color)
		@tileset[tiles[:topright]].draw((x+width-1)*16,y*16,0,1,1,color)
		@tileset[tiles[:bottomright]].draw((x+width-1)*16,(y+height-1)*16,0,1,1,color)
		@tileset[tiles[:bottomleft]].draw(x*16,(y+height-1)*16,0,1,1,color)
		(width-1).times do |i| #draw horizontal borders; since width is a total, we substract 1
			@tileset[tiles[:horizontal]].draw((x+i+1)*16,y*16,0,1,1,color)
			@tileset[tiles[:horizontal]].draw((x+i+1)*16,(y+height-1)*16,0,1,1,color)
			end
		(height-1).times do |j| #draw vertical borders
			@tileset[tiles[:vertical]].draw(x*16,(y+1+j)*16,0,1,1,color)
			@tileset[tiles[:vertical]].draw((x+width-1)*16,(y+1+j)*16,0,1,1,color)
			end
	end
end