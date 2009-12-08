# Display handles drawing of any kind. There are three ways to draw stuff.
# Text: It takes a string and converts it into array of symbols to be drawn.
# Buffer: The actual game state is stored in the buffer, which Display reads and draws stuff.
# GUI (frames, 'selectors' etc.) - context sensitive!
# 
require 'gosu'

module Interface
	def draw_tiles(x,y,content,direction=:horizontal,color=0xFFFFFFFF)
		#expected argument must be either a Symbol or an Array of symbols
		# Draws either the one tile or a number of tiles into given direction
		if content.class==Symbol then
			@tileset[content].draw(x*16,y*16,0,1,1,color)
		elsif content.class==Array and direction==:horizontal then
			content.length.times {|i| @tileset[content[i]].draw((x+i)*16,y*16,0,1,1,color)}
		elsif content.class==Array and direction==:vertical then
			content.length.times {|j| @tileset[content[j]].draw(x*16,(y+j)*16,0,1,1,color)}
		end
	end
	
	# draw a rectangular frame
	def draw_frame(x,y,width,height,type=:double,color=0xFFFFFFFF)
		case type
			when :double then
				tiles={:topleft => :table_topleft_double, :topright => :table_topright_double, :bottomright => :table_bottomright_double, :bottomleft => :table_bottomleft_double, :horizontal => :table_horizontal_double, :vertical => :table_vertical_double}
			when :single then
				tiles={:topleft => :table_topleft_single, :topright => :table_topright_single, :bottomright => :table_bottomright_single, :bottomleft => :table_bottomleft_single, :horizontal => :table_horizontal_single, :vertical => :table_vertical_single} 
			when :solid then 
				tiles={:topleft => :fill100, :topright => :fill100, :bottomright => :fill100, :bottomleft => :fill100, :horizontal => :fill100, :vertical => :fill100}
			when :heart then
				tiles={:topleft => :heart, :topright => :heart, :bottomright => :heart, :bottomleft => :heart, :horizontal => :heart, :vertical => :heart}
		end
		draw_tiles(x,y,tiles[:topleft],:horizontal,color)
		draw_tiles(x+width-1,y,tiles[:topright],:horizontal,color)
		draw_tiles(x+width-1,y+height-1,tiles[:bottomright],:horizontal,color)
		draw_tiles(x,y+height-1,tiles[:bottomleft],:horizontal,color)
		draw_tiles(x+1,y,[tiles[:horizontal]]*(width-2),:horizontal,color)
		draw_tiles(x+1,y+height-1,[tiles[:horizontal]]*(width-2),:horizontal,color)
		draw_tiles(x,y+1,[tiles[:vertical]]*(height-2),:vertical,color)
		draw_tiles(x+width-1,y+1,[tiles[:vertical]]*(height-2),:vertical,color)
	end
end