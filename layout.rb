# Layout class is the interface between game and player.
# Layout class is designed to contain common tasks and to be inherited by specialized classes.

class Layout
  include Updatable
  include Drawable
  include Inputable
  attr_accessor :state, :keys, :current_button
  
  def initialize
    @state = :initialized
    @keys = []
  end
  
  def update
  end
  
  def draw
  end
  
  def remove
    Updatable::remove(self)
    Drawable::remove(self)
    Inputable::remove(self)
  end
end

class Test < Layout
  KEYS = ALPHANUMERIC + [:esc, :up, :down, :enter]
  
  def initialize
    @keys=[]
    $game.caption = "Test Layout Screen"
    @state = :main
  end
  
  def update
    if Keys.triggered?(self,:esc) then
      self.remove
      $game.change_layout(Title)
    end
  end
  
  def draw
    Display.blit_rot(32,24,1,:diamond,  0xFFFF0000,Gosu::milliseconds()*0.1%360,[48,48])
    Display.blit_text(1,1,1,"Hit ESC to return", 0xFFAAAAAA)
    Display.blit_text(22,47,1,"Pretend this is a ruby", 0xFFAAAACC)
    Display.blit_text(1,0,1,"Time between ticks: #{$game.timedelta} ms",0xFFAAAAAA)
    Display.blit_line(0,2,64,0,GRADIENT_GREYSCALE,:fill)
    Display.blit_line(0,3,64,0,Gradient.new(0xFF000000,0xFFFF0000,0xFFFF00FF),:fill)
    Display.blit_line(0,4,64,0,GRADIENT_COLOR_MAP,:fill)
    Display.neat_text(1,5,0,"This is a REALLY neat text! Don't you think so? Aw, come on.", Gradient.new(0xFFFFFF00,0xFFFF0000,0xFFFF00FF,0xFF00FFFF))
    Display.blit_text(6,8,0,"Woohoo vertical text!",0xFF00FFFF,false)
    Display.blit_bresenham(1,40,62,8,0,0xFF00FF00,:ring)
  end
end

class Title < Layout
  KEYS = [:esc, :up, :down, :enter]
  
  def initialize
    super
    $game.caption = "Title Layout Test"
    @state = :main #root level
    # buttons
    @b_newgame=Button.new(24,16,"New Game"){ puts "New game pressed"}
    @b_test1=Button.new(24,18,"Test Layout"){ self.remove; $game.change_layout(Test)}
    @b_options=Button.new(24,20,"Options"){ self.remove; $game.change_layout(Options)}
    @b_quit=Button.new(24,23,"Exit",false){$game.close}
    @hotkeys = {:esc => @b_quit}
    @b_newgame.disable
    @b_newgame.prev = @b_quit; @b_newgame.next = @b_test1
    @b_test1.prev = @b_newgame; @b_test1.next = @b_options
    @b_options.prev=@b_test1; @b_options.next = @b_quit
    @b_quit.prev = @b_options; @b_quit.next = @b_newgame
    @current_button=@b_test1; @b_test1.select
    
  end
  
  def update
    @hotkeys.each {|key,value| value.action if Keys.triggered?(self,key)}
    @current_button=@current_button.next_button if Keys.ready?(self,:down)
    @current_button=@current_button.prev_button if Keys.ready?(self,:up)
    @current_button.action if Keys.triggered?(self, :enter)
  end
  
  def draw
    GAME_TITLE.length.times do |i|
      Display.blit_rot(5+i*4,3,0,GAME_TITLE[i].intern,0xFFFF0000,0,[4,4])
    end
    Display.blit_line(0,0,SCREEN_TILE_WIDTH,0,0xFFAAAAAA,:fill100)
    Display.blit_line(0,SCREEN_TILE_HEIGHT-1,SCREEN_TILE_WIDTH,0,0xFFAAAAAA,:fill100)
    Display.blit_line(0,1,SCREEN_TILE_HEIGHT-2,0,0xFFAAAAAA,:fill100,false)
    Display.blit_line(SCREEN_TILE_WIDTH-1,1,SCREEN_TILE_HEIGHT-2,0,0xFFAAAAAA,:fill100,false)
    Display.blit_text(SCREEN_TILE_WIDTH-8,SCREEN_TILE_HEIGHT-1,2,VERSION,0xFF444444)
  end
  
  def remove
    super
    Handler.destroy(@b_newgame,@b_test1,@b_options,@b_quit)
  end  
end

class Options < Layout
  KEYS = [:esc, :up, :left, :down, :right, :enter, :page_down, :page_up, :end, :home] + ALPHANUMERIC
  def initialize
    super
    $game.caption = "Options"
    @state = :main
    init_interface
    @hotkeys = {:esc => @b_quit}
  end
  
  def init_interface
    @b_quit = Button.new(1,1,"Return to Title"){ 
      (@state==:main) ? 
        (begin self.remove; $game.change_layout(Title) end) : 
        (begin 
            @state=:main 
            @b_game.enable
            @b_display.enable
            @b_quit.text="Return to Title"
          end)}
    @b_display = Button.new(1,4,"Display Options"){
      @state= :display
      @b_display.unselect 
      @current_button=@b_quit
      @b_quit.select
      }
    @b_game = Button.new(1,5,"Game Options"){
      @state= :game 
      @b_game.unselect 
      @current_button=@b_quit 
      @b_quit.select
      }
    @current_button=@b_display; @b_display.select
    @b_display.prev=@b_quit; @b_display.next=@b_game
    @b_game.prev=@b_display;@b_game.next=@b_quit
    @b_quit.next=@b_display; @b_quit.prev=@b_game
  end
  
  def remove
    super
    Handler.destroy(@b_quit,@b_display,@b_game)
  end
  
  def update
    @hotkeys.each {|key,value| value.action if Keys.triggered?(self,key)}
    @current_button.action if Keys.triggered?(self,:enter)
    @current_button=@current_button.next_button if Keys.ready?(self,:down)
    @current_button=@current_button.prev_button if Keys.ready?(self,:up)
    
    if @state != :main then
      @b_display.disable
      @b_game.disable
      @b_quit.text="Cancel"
    end
  end
  
  def draw
    if @state == :game then
      text="No game options available yet"
      x=32-text.length/2
      Display.blit_text(x,24,LAYER_TEXT,text, 0xFF0088AA)
      Display.blit_frame(x-1,23,x+text.length,25,LAYER_TEXT,:single,0xFF0088AA)
    elsif @state == :display then
      text="No display options available yet"
      x=32-text.length/2
      Display.blit_text(x,24,LAYER_TEXT,text, 0xFF0088AA)
      Display.blit_frame(x-1,23,x+text.length,25,LAYER_TEXT,:single,0xFF0088AA)
    else
      text="Please select appropriate options"
      x=32-text.length/2
      Display.blit_text(x,24,LAYER_TEXT,text, 0xFF0088AA)
      Display.blit_frame(x-1,23,x+text.length,25,LAYER_TEXT,:single,0xFF0088AA)
    end  
  end
  

end