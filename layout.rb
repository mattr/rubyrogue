# Layout class is the interface between game and player.
# Layout class is designed to contain common tasks and to be inherited by specialized classes.

class Layout
  include Updatable
  include Drawable
  include Inputable
  attr_accessor :state, :keys, :current_button, :buttons

  def initialize
    @state = :initialized
    @keys = []
    @buttons = {}
  end

  def update
  end
  
  def draw
  end
  
  def next_button(button)
    if @buttons[button].next then
      if @buttons[@buttons[button].next].enabled? then
        @buttons[@current_button].unselect
        @current_button=@buttons[button].next
        @buttons[@current_button].select
      else
        next_button(@buttons[button].next)
      end
    else
      return nil
    end
  end
  
  def prev_button(button)
    if @buttons[button].prev then
      if @buttons[@buttons[button].prev].enabled? then
        @buttons[@current_button].unselect
        @current_button=@buttons[button].prev
        @buttons[@current_button].select
      else
        prev_button(@buttons[button].prev)
      end
    else
      return nil
    end    
  end
  
  def remove
    @buttons.each_value {|button| button.remove} if @buttons
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
    Display.blit_line(0,2,64,0,:fill,GRADIENT_GREYSCALE)
    Display.blit_line(0,3,64,0,:fill,Gradient.new(0xFF000000,0xFFFF0000,0xFFFF00FF))
    Display.blit_line(0,4,64,0,:fill,GRADIENT_COLOR_MAP)
    Display.neat_text(1,5,0,"This is a REALLY neat text! Don't you think so? Aw, come on.", Gradient.new(0xFFFFFF00,0xFFFF0000,0xFFFF00FF,0xFF00FFFF))
    Display.blit_text(6,8,0,"Woohoo vertical text!",0xFF00FFFF,false)
    Display.blit_bresenham(1,40,62,8,0,0xFF00FF00,:ring)
  end
end

class Title < Layout
  KEYS = [:esc, :up, :down, :enter]
  BUTTONS = { # :name => [x,y,text,toggle,prev,next,action]
    :newgame => [24,16,"New game", false,nil,:test,Proc.new{puts "New Game"}],
    :test => [24,18,"Layout Test", false,:newgame,:options,Proc.new{self.remove; $game.change_layout(Test)}],
    :options => [24,20,"Options", false,:test,:exit,Proc.new{self.remove; $game.change_layout(Options)}],
    :exit => [24,23,"Exit",false,:options,nil,Proc.new{$game.quit}]
    }


  def initialize
    super
    $game.caption = "Title Layout Test"
    @state = :main #root level

    # buttons - parameters: x,y,text,togglable,prev,next, action
    @buttons={
    :newgame => Button.new(24,16,"New game",false,:exit,:test){
      puts "New Game"},
    :test => Button.new(24,18,"Layout Test",false,:newgame,:options){
      self.remove; $game.change_layout(Test)},
    :options => Button.new(24,20,"Options",false,:test,:exit){
      self.remove; $game.change_layout(Options)},
    :exit => Button.new(24,23,"Exit",false,:options,:newgame){$game.quit}
    }
    @hotkeys = {:esc => :exit}
    @current_button=:newgame
    @buttons[@current_button].select
    
  end
  
  def update
    @hotkeys.each {|key,value| @buttons[value].action if Keys.triggered?(self,key)}
    next_button(@current_button) if Keys.ready?(self,:down)
    prev_button(@current_button) if Keys.ready?(self,:up)
    @buttons[@current_button].action if Keys.triggered?(self, :enter)
  end
  
  def draw
    GAME_TITLE.length.times do |i|
      Display.blit_rot(5+i*4,3,0,GAME_TITLE[i].intern,0xFFFF0000,0,[4,4])
    end
    Display.blit_frame(0,0,63,47,1,:double,0xFF888888)
    Display.blit_text(SCREEN_TILE_WIDTH-8,SCREEN_TILE_HEIGHT-2,2,VERSION,0xFF888888)
  end
  
  def remove
    super

  end  
end

class Options < Layout
  KEYS = [:esc, :up, :left, :down, :right, :enter, :page_down, :page_up, :end, :home] + ALPHANUMERIC
      
  def initialize
    super
    $game.caption = "Options"
    @state = :main
    
    @buttons={
      :return => Button.new(1,1,"Return to Title",false,nil,:display){
        (@state==:main)?
        begin 
          self.remove
          $game.change_layout(Title) 
        end :
        begin 
            @state=:main 
            @buttons[:game].enable
            @buttons[:display].enable
            @buttons[:return].text="Return to Title"
          end},
      :display => Button.new(1,4,"Display Options",false,:return,:game){
        @state= :display
        @buttons[:display].unselect 
        @current_button=:return
        @buttons[:return].select
        },
      :game => Button.new(1,5,"Game Options",false,:display,nil){
        @state= :game 
        @buttons[:game].unselect 
        @current_button=:return 
        @buttons[:return].select
        }
    }
    
    @current_button=:display
    @buttons[:display].select
    @hotkeys = {:esc => :return}
  end
  
  def remove
    super
  end
  
  def update
    @hotkeys.each {|key,value| @buttons[value].action if Keys.triggered?(self,key)}
    @buttons[@current_button].action if Keys.triggered?(self,:enter)
    next_button(@current_button) if Keys.ready?(self,:down)
    prev_button(@current_button) if Keys.ready?(self,:up)
    
    if @state != :main then
      @buttons[:display].disable
      @buttons[:game].disable
      @buttons[:return].text="Cancel"
    end
  end
  
  def draw
    if @current_button == :game and @state == :main then
      text="No game options available yet"
      x=32-text.length/2
      Display.blit_text(x,24,LAYER_TEXT,text, 0xFF0088AA)
      Display.blit_frame(x-1,23,x+text.length,25,LAYER_TEXT,:single,0xFF0088AA)
    elsif @current_button == :display and @state == :main then
      text="No display options available yet"
      x=32-text.length/2
      Display.blit_text(x,24,LAYER_TEXT,text, 0xFF0088AA)
      Display.blit_frame(x-1,23,x+text.length,25,LAYER_TEXT,:single,0xFF0088AA)
    elsif @state == :main then
      text="Please select options"
      x=32-text.length/2
      Display.blit_text(x,24,LAYER_TEXT,text, 0xFF0088AA)
      Display.blit_frame(x-1,23,x+text.length,25,LAYER_TEXT,:single,0xFF0088AA)
    else
      #nothing
    end  
  end
end