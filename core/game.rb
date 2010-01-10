# GameScreen

class GameScreen
  include Updatable
  include Drawable
  include Inputable
  attr_accessor :keys, :world
  
  KEYS = [:left, :right, :up, :down, :esc]
  
  def initialize(world)
    @world=world
    @border_frame=create(@border_frame,Frame,0,0,SCREEN_TILE_WIDTH,SCREEN_TILE_HEIGHT,0, 0xFF888888,:fill100)
    @keys=[]
    @buffer=[]
    @offset_x=-32
    @offset_y=-24
  end
  
  def update
    self.remove if Keys.triggered?(self, :esc)
    
    @offset_y+=1 if Keys.ready?(self,:down)
    @offset_y-=1 if Keys.ready?(self,:up)
    @offset_x+=1 if Keys.ready?(self,:right)
    @offset_x-=1 if Keys.ready?(self,:left)
  end

  def draw
    #this is just test drawing code, the camera is not implemented yet
    46.times do |j|
      62.times do |i|
        y=j+@offset_y
        x=i+@offset_x
        if @world[y,x] != nil then
          cell=@world[y,x][MAP_VISIBLE]
          Display.blit(i+1,j+1,0,cell[0],cell[1])
        end
      end
    end
    Display.blit(32,24,1,:face_full,0xFFFFAA44)
  end
  
  def remove
    Updatable::remove(self)
    Drawable::remove(self)
    Inputable::remove(self)
    Handler.destroy(@border_frame)
    $game.state=:title
  end
  
end