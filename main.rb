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

include Handler
include Math

class MainWindow < Gosu::Window
  attr_accessor :tileset, :keys
  def initialize
    super(SCREEN_SIZE[0],SCREEN_SIZE[1],FULLSCREEN,1.0/FPS_LIMIT)
    self.caption="Work in progress."
    @tileset=Tileset.new(self)
    @seed=0
    @heightmap=read_pgm('./images/world.pgm')
  end
  def read_pgm(filename)
    array = IO.readlines(filename)
    header = []
    while header.length < 3 do
      line = array.shift.chomp
      header << line unless line =~ /\A\s*#/
    end
    raise "Wrong file type: #{header[0]} instead of P2" unless header[0] == 'P2'
    width, height = header[1].split(/\s+/).collect{|t| t.to_i}
    max_value = header[2].to_i
    raw = array.join.split(/\s+/).collect{|t| t.to_i}
    unless max_value == 255 then
      d = (max_value+1)/256
      raw.collect!{|v| v/d} # scales everything into the 0..255 integer range
    end
    matrix = []
    height.times do |y|
      matrix << raw[y*width, width]
    end
    return matrix
  end

def draw
    start=Gosu::milliseconds
    Drawable.do!
    
    48.times do |j|
     48.times do |i|
        shade=@heightmap[j*10][i*10]
        Display.blit(i,j,0,:fill,Gosu::Color.new(shade,shade,shade))
      end
    end
 
    @draw_time=Gosu::milliseconds-start
  end
  
  def update
    start=Gosu::milliseconds()
    Inputable::input=Input::read_keys(self) #comes before Inputable.do!
    Inputable.do! # comes before Updatable.do!
    @keys=Inputable::input
    Updatable.do!
    
        @frame.width=@text.content.length+2 if @text
    
    ######### Test code begins here
    
  
    
    ######## Test code ends here
    
    self.close if Keys.triggered?(self,:esc)
    
    update_time = Gosu::milliseconds()-start #benchmark end
    total=@draw_time+update_time
    self.caption = "Draw: "+@draw_time.to_s+" ms | Logic: "+update_time.to_s+" ms | Total: "+total.to_s+" ms | FPS: "+(1000.0/total).to_s
  end
  
end

# Global variable that holds the reference to the main game window, useful for reaching it
$game=MainWindow.new
$game.show