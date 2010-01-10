require 'gosu'
require './config.rb'
require './core/display'
require './core/misc'
require './core/handler'
require './core/gradient'
require './core/constants'
require './core/input'
require './core/gui'
require './core/world'
require './core/noise'
require './read_pgm'
require './core/title'
require './core/game'

include Handler
include Math

class MainWindow < Gosu::Window
  attr_accessor :tileset, :keys, :screen, :state
  def initialize
    super(SCREEN_SIZE[0],SCREEN_SIZE[1],FULLSCREEN,1.0/FPS_LIMIT)
    self.caption="Work in progress."
    @tileset=Tileset.new(self)
    @state = :title #game state, use symbols
  end
  
  def draw
    start=Gosu::milliseconds
    Drawable.do!
    
    ######### Test code begin
    
    
    ######### Test code end
    
    @draw_time=Gosu::milliseconds-start
  end
  
  def update
    start=Gosu::milliseconds()
    Inputable::input=Input::read_keys(self) #comes before Inputable.do!
    Inputable.do! # comes before Updatable.do!
    @keys=Inputable::input
    Updatable.do!
    
    ######### Test code begins here

    if @state == :title then 
      @screen=create(@screen,TitleScreen)
      @state = :busy
    elsif @state == :create_world then
      @world = World.new(:random,8,8){|k| self.caption=k}
      @state = :game
    elsif @state == :game
      #start the game
      @screen=create(@screen,GameScreen,@world)
      @state = :busy
    else
    end
    ######## Test code ends here
    
    update_time = Gosu::milliseconds()-start #benchmark end
    total=@draw_time+update_time
    self.caption = "Draw: "+@draw_time.to_s+" ms | Logic: "+update_time.to_s+" ms | Total: "+total.to_s+" ms | FPS: "+(1000.0/total).to_s
  end  
end

# Global variable that holds the reference to the main game window, useful for reaching it
$game=MainWindow.new
$game.show