require 'gosu'
require 'input'
require 'display'
require 'tileset'
require 'cut' # various snippets such as the new rand()
require 'noise'
require 'handler'
require 'world'

  include Interface
  include Math
  include Handler

class GameWindow < Gosu::Window
	attr_accessor :keys, :WIDTH, :HEIGHT
	Background, Base, Foreground, Overlay = *0..3 # Z levels
	WIDTH, HEIGHT = 64, 48 # width and height in tiles, based on 1024x768 with 16x16 tiles
	
# advanced initialization, not really needed now
  #~ def initialize(ini)
    #~ x=ini['Display']['DisplayX']
    #~ y=ini['Display']['DisplayY']
    #~ z=ini['Display']['Fullscreen']
    #~ super(x.to_i,y.to_i,z.to_i)
  def initialize
    super(1024, 768, 0)
    self.caption="Generic title"
    @tileset=Tileset.new(self)
    @keys=[]
    Interface::tileset=@tileset
    @update_time, @cursor_x, @cursor_y = 0, 0, 0
    @debug1=create(@debug1, Text, 0, 0, "Press 1 to generate world map", 0xFFFFFF22)
    @debug2=create(@debug2, Text, 1, 47,  '',0xFFAAAAAA)
    @seed=0
    @cursor_x=@cursor_y=0
  end
    
  def update()
    start = Gosu::milliseconds() #benchmark start
    
    Inputable.input = Input::read_keys(self) #needs to come before Inputable.do!
    Inputable.do! #should come before Updatable::do!
    @keys = Inputable.input
    Updatable::do!

    #~ #update camera targets
    @camera1.target=@world.regions[0][0] if @camera1
    @camera2.target=@world.regions[0][1] if @camera2
    @camera3.target=@world.regions[0][2] if @camera3
    @camera4.target=@world.regions[1][0] if @camera4
    @camera5.target=@world.regions[1][1] if @camera5
    @camera6.target=@world.regions[1][2] if @camera6
    @camera7.target=@world.regions[2][0] if @camera7
    @camera8.target=@world.regions[2][1] if @camera8
    @camera9.target=@world.regions[2][2] if @camera9
    
    # shows the value at camera coordinates
    @debug2.content='['+@cursor_x.to_s+','+@cursor_y.to_s+'] = '+@world.values[@cursor_y][@cursor_x].to_s if @world
    
    if Keys.triggered?(self, :'1') then 
      @debug1.remove if @debug1
      @seed += 1
      cam_x = 8
      cam_y = 8
      @world = create(@world, World, 128, 128, @seed)
      @cursor_x=@world.width/2
      @cursor_y=@world.height/2
      @world.update_regions(@cursor_x,@cursor_y)
      @world_camera = create(@world_camera, Camera, @cursor_x, @cursor_y, 32, 32, @world, [true, false])
      @world_view= create(@world_view, Viewport, 0, 0, @world_camera)
      @camera1 = create(@camera1, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[1][1])
      @camera2 = create(@camera2, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[0][1])
      @camera3 = create(@camera3, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[0][2])
      @camera4 = create(@camera4, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[1][0])
      @camera5 = create(@camera5, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[1][1])
      @camera6 = create(@camera6, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[1][2])
      @camera7 = create(@camera7, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[2][0])
      @camera8 = create(@camera8, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[2][1])
      @camera9 = create(@camera9, Camera, cam_x/2, cam_y/2, cam_x, cam_y, @world.regions[2][2])
      @view1 = create(@view1, Viewport, 33+cam_x*0, 1+cam_y*0, @camera1)
      @view2 = create(@view2, Viewport, 33+cam_x*1, 1+cam_y*0, @camera2)
      @view3 = create(@view3, Viewport, 33+cam_x*2, 1+cam_y*0, @camera3)
      @view4 = create(@view4, Viewport, 33+cam_x*0, 1+cam_y*1, @camera4)
      @view5 = create(@view5, Viewport, 33+cam_x*1, 1+cam_y*1, @camera5)
      @view6 = create(@view6, Viewport, 33+cam_x*2, 1+cam_y*1, @camera6)
      @view7 = create(@view7, Viewport, 33+cam_x*0, 1+cam_y*2, @camera7)
      @view8 = create(@view8, Viewport, 33+cam_x*1, 1+cam_y*2, @camera8)
      @view9 = create(@view9, Viewport, 33+cam_x*2, 1+cam_y*2, @camera9)
    end
    
    if @world then
      if Keys.ready?(self, :left) then
        @cursor_x -= 1
        @cursor_x=@cursor_x%@world.width
        @world_camera.x=@cursor_x
        @world.change_region(:left)
      end
      
      if Keys.ready?(self, :right) then
        @cursor_x+=1
        @cursor_x=@cursor_x%@world.width
        @world_camera.x=@cursor_x
        @world.change_region(:right)
      end
        
      if Keys.ready?(self, :up) and @cursor_y>1 then
        @cursor_y-= 1
        @world_camera.y=@cursor_y
        @world.change_region(:up)
      end
        
      if Keys.ready?(self, :down) and @cursor_y<@world.height-2 then    
        @cursor_y+= 1 
        @world_camera.y=@cursor_y
        @world.change_region(:down)
      end
  end
    
    close if Keys.triggered?(self,:esc)
    
    @update_time=Gosu::milliseconds()-start #benchmark end
  end
  
  def draw()
    start = Gosu::milliseconds() #benchmark start
    
    Drawable::do!
    
    # abstracted world map
    16.times do |j|
      16.times do |i|
        Interface::draw_tiles(33+i,29+j,0,:fill,@world.map[j*(@world.height/16)][i*(@world.width/16)][1]) if @world
      end
    end
    Interface::draw_tiles(16,16,1,:border,0xFFFFFF66) if @world
    Interface::draw_tiles(33+@cursor_x/(@world.width/16),29+@cursor_y/(@world.height/16),1,:border,0xFFFFFF66) if @world
    
    # draw_frame params: (x,y,width,height,Z, color, style) styles: :double, :single, :solid, :heart
    # draw_tiles params: (x,y,Z, symbol or array of symbols, color, :horizontal or :vertical)
    # Z order: Background, Base, Foreground, Overlay
    # draw_text(x,y,text,color) - Z always at 1 to be drawn above everything else
    # draw_buffer(x,y,width,height,buffer,off_x,off_y)

    update_draw = Gosu::milliseconds()-start #benchmark end
    self.caption = (@update_time+update_draw).to_s+" ms"
  end
end

#Game=GameWindow.new(IniFile.new('config.ini'))
Game = GameWindow.new
Game.show