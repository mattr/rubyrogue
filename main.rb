require 'gosu'
require 'keyboard'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()

COLORS={
	:white => 0xFFFFFFFF,
	:red => 0xFFFF0000,
	:green => 0xFF00FF00,
	:blue => 0xFF0000FF,
	:yellow => 0xFFFFFF00,
	:purple => 0xFFFF00FF,
	:cyan => 0xFF00FFFF,
	:gray => 0xFFAAAAAA
}

class GameWindow < Gosu::Window
	attr_accessor :keys, :WIDTH, :HEIGHT
	Background, Base, Foreground, Overlay = *0..3 # Z levels
	WIDTH, HEIGHT = 64, 48 # width and height in tiles, based on 1024x768 with 16x16 tiles
# advanced initialization, not really needed now
#  def initialize(ini)
#    x=ini['Display']['DisplayX']
#    y=ini['Display']['DisplayY']
#    z=ini['Display']['Fullscreen']
#    super(x.to_i,y.to_i,z.to_i)
  
  include Interface
  include Math

  def initialize
    super(1024, 768, 0)
    self.caption="Generic title"
    @tileset=Tileset.new(self)
    Interface::tileset=@tileset
    @color=Gosu::Color.new(255, 255, 0, 0)
    @buffer=[]
    64.times do |i|
      @buffer << []
      48.times do |j|
        @buffer[i][j]=[Tileset::SYMBOLS[rand(256)], COLORS.values[rand(COLORS.keys.length)]]
      end
    end
    @update_time=0
    @keys=Input::active
    @cur_x=0
    @cur_y=0
    @state=:default
  end
  
  def update()
    start = Gosu::milliseconds() #benchmark start
    
    #this is just for a neat effect to test buffer display
    4.times do @buffer[rand(64)][rand(48)]=[rand([:fill25,:fill50,:fill75,:fill100]),rand([0xFFFFFFFF,0xFFEEEEEE,0xFFDDDDDD,0xFFCCCCCC,0xFFBBBBBB,0xFFAAAAAA,0xFF999999,0xFF888888,0xFF777777,0xFF666666,0xFF555555,0xFF444444,0xFF333333,0xFF222222,0xFF111111,0xFF000000])] end
    
    Input::read(self) # the trick is that once GameWindow::keys refers to Input::keys, there's no need to set GameWindow::keys every tick

    if Input::triggered?(:N) and not @test then
	Input::triggered.delete(:N)
	@state=:input
	@test=TextInput.new(1, 27, 'Default text')
    end
    if @test then
	ed = @test.edit
      if ed[0] == :ok then
	puts ed[1]
        @test=nil
	@state=:default
      elsif ed[0] == :cancel then
        puts ed[1]
	@state=:default
        @test=nil
      else
        #nothing
      end
    end
    
    # for manual buffer window
    if @state==:default then
	if Input::is_pressed?(:left) and @cur_x>0 then @cur_x-=1 end
	if Input::is_pressed?(:right) and @cur_x<54 then @cur_x+=1 end
        if Input::is_pressed?(:up) and @cur_y>0 then @cur_y-=1 end
        if Input::is_pressed?(:down) and @cur_y<38 then @cur_y+=1 end
     end
    @update_time=Gosu::milliseconds()-start #benchmark end
  end
  
  def draw()
	start = Gosu::milliseconds() #benchmark start
	
	#draw_frame params: (x,y,width,height,Z, color, style) styles: :double, :single, :solid, :heart
	#draw_tiles params: (x,y,Z, symbol or array of symbols, color, :horizontal or :vertical)
	# Z order: Background, Base, Foreground, Overlay
	#draw_text(x,y,text,color) - Z always at 1 to be drawn above everything else
	
	draw_frame(0, 0, 64, 26, Foreground, 0xFF999999, :single)
	draw_buffer(1, 1, 10, 10, @buffer)
	draw_text(1,11,"Top left")
	draw_buffer(12,1,10,10, @buffer,0,9)
	draw_text(12,11,"Y+9")
	draw_buffer(23,1,10,10, @buffer,9,0)
	draw_text(23,11,"X+9")
	draw_buffer(34,1,10,10, @buffer,9,9)
	draw_text(34,11,"X+9,Y+9")
	draw_buffer(45,1,10,10, @buffer,@cur_x,@cur_y)
	draw_text(45,11,"Manual view")
	draw_buffer(1,15,62,10,@buffer,0,38)
	draw_text(1,14,"Bottom part of the buffer",0xFFDDDDDD)
	
	
	draw_text(1, 26, "TextInput test, press", 0xFFFFFFAA)
	draw_text(22, 26," n ",0xFF00FFFF)
	draw_text(25, 26,"to begin typing.", 0xFFFFFFAA)
	draw_text(1, 46, @keys.inspect.to_s , 0xFFFFFFFF) 
	draw_text(1,47,Input::triggered*",",0xFFCCCCCC) 
	if @test then @test.draw end

	update_draw = Gosu::milliseconds()-start #benchmark end
	self.caption=(@update_time+update_draw).to_s+" ms"
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game=GameWindow.new
Game.show