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
    @keys=[]
    $game.caption = "Title Layout Test"
    @state = :main #root level
    # buttons
    @b_newgame=Button.new(24,16,"New Game"){ puts "New game pressed"}
    @b_test1=Button.new(24,17,"Test Layout"){ self.remove; $game.change_layout(Test)}
    @b_test2=Button.new(24,18,"Test Button Toggle",true){@b_test2.text=(@b_test2.toggled?) ? "Toggled ON" : "Toggled OFF"}
    @b_quit=Button.new(24,20,"Exit",false){$game.close}
    @hotkeys = {:esc => @b_quit}
    @b_newgame.disable
    @b_newgame.prev = @b_quit; @b_newgame.next = @b_test1
    @b_test1.prev = @b_newgame; @b_test1.next = @b_test2
    @b_test2.prev = @b_test1; @b_test2.next = @b_quit
    @b_quit.prev = @b_test2; @b_quit.next = @b_newgame
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
    Display.blit_text(1,SCREEN_TILE_HEIGHT-2,1,"Hit ESC to exit, ENTER to test layout change",0xFFAAAAAA) if @state == :main
    Display.blit_line(0,0,SCREEN_TILE_WIDTH,0,0xFFAAAAAA,:fill100)
    Display.blit_line(0,SCREEN_TILE_HEIGHT-1,SCREEN_TILE_WIDTH,0,0xFFAAAAAA,:fill100)
    Display.blit_line(0,1,SCREEN_TILE_HEIGHT-2,0,0xFFAAAAAA,:fill100,false)
    Display.blit_line(SCREEN_TILE_WIDTH-1,1,SCREEN_TILE_HEIGHT-2,0,0xFFAAAAAA,:fill100,false)
    Display.blit_text(SCREEN_TILE_WIDTH-8,SCREEN_TILE_HEIGHT-1,2,VERSION,0xFF444444)
  end
  
  def remove
    super
    Handler.destroy(@b_newgame,@b_test1,@b_test2,@b_quit)
  end  
end