require 'cut'
require 'noise'
require 'gosu'
require 'handler'

class World
  include Updatable
  # Builds and manages game areas and locations
  # Order of scale: World > Region > Area > Tile/Node
  attr_accessor :width, :height, :seed, :map, :values, :regions, :noise
  @width, @height = 16,16
  @seed = 0
  @values = [] #processed fractal noise
  @map = [] #world map converted from noise

  
  def initialize(width=16, height=16, seed=0)
    @width, @height, @seed = width, height, seed
    @regions=[[0,0,0],[0,0,0],[0,0,0]] # 3x3 array of preloaded regions; current region is always [1][1]
    create_world()
    # load values
  end
  
  def translate(map) #return an array of symbols and colors for display purposes
    array=Array.new(map.length){Array.new(map[0].length, 0)}
    map.length.times do |j|
      map[j].length.times do |i|
        shade = ((255*map[j][i]).to_i)
        array[j][i] = [:fill, Gosu::Color.new(shade,shade,shade)]
      end
    end
    return array
  end
  
  def boost_constract(base) #rescale everything to (0,1) range
    base_min = base.collect{|row| row.min}.min
    base_max = base.collect{|row| row.max}.max
    base.each{|row| row.collect!{|cell| (cell-base_min)/(base_max-base_min)}}
  end
  
  def create_world() #create the world map
    #~ persists=[0,0.5,0.25] #only need three octaves for now
    #~ offsets=Array.new(3,[0,0])
    srand(@seed)
    @noise = Array.new(@height){Array.new(@width){rand}} # intitial noise
    srand
    @values = Array.new(@height){Array.new(@width, 0.0)}
    # First octave
    FractalNoise.octave(3, 1, @values, @noise,  0.5, [0,0], [true,false])
    #Second octave
    FractalNoise.octave(3, 2, @values, @noise,  0.25, [0,0], [true,false])
    #Third octave
    FractalNoise.octave(3, 3, @values, @noise,  0.125, [0,0], [true,false])
    
    boost_constract(@values)
    @map = translate(@values)
    
    #populate the regions buffer at start
    @regions=[[Region.new(self,@width-1,@height-1),Region.new(self,0,@height-1),Region.new(self,1,@height-1)],
    [Region.new(self,@width-1,0),Region.new(self,0,0),Region.new(self,1,0)],
    [Region.new(self,@width-1,1),Region.new(self,0,1),Region.new(self,1,1)]]
  end
  
  def change_region(direction)
    current_x=@regions[1][1].x
    current_y=@regions[1][1].y
    case direction
      when :left
        #shift array right, create three left cells
        @regions[0][2]=@regions[0][1];@regions[0][1]=@regions[0][0]; @regions[0][0] = Region.new(self,current_x-2,current_y-1)
        @regions[1][2]=@regions[1][1];@regions[1][1]=@regions[1][0]; @regions[1][0] = Region.new(self,current_x-2,current_y)
        @regions[2][2]=@regions[2][1];@regions[2][1]=@regions[2][0]; @regions[2][0] = Region.new(self,current_x-2,current_y+1)
      when  :right
        #shift array left, create three right cells
        @regions[0][0]=@regions[0][1];@regions[0][1]=@regions[0][2]; @regions[0][2] = Region.new(self,current_x+2,current_y-1)
        @regions[1][0]=@regions[1][1];@regions[1][1]=@regions[1][2]; @regions[1][2] = Region.new(self,current_x+2,current_y)
        @regions[2][0]=@regions[2][1];@regions[2][1]=@regions[2][2]; @regions[2][2] = Region.new(self,current_x+2,current_y+1)
      when :up
        #shift array down, create three top cells
        @regions[2][0]=@regions[1][0];@regions[1][0]=@regions[0][0]; @regions[0][0] = Region.new(self,current_x-1,current_y-2)
        @regions[2][1]=@regions[1][1];@regions[1][1]=@regions[0][1]; @regions[0][1] = Region.new(self,current_x,current_y-2)
        @regions[2][2]=@regions[1][2];@regions[1][2]=@regions[0][2]; @regions[0][2] = Region.new(self,current_x+1,current_y-2)
      when :down
        #shift array up, create three bottom cells
        @regions[0][0]=@regions[1][0];@regions[1][0]=@regions[2][0]; @regions[2][0] = Region.new(self,current_x-1,current_y+2)
        @regions[0][1]=@regions[1][1];@regions[1][1]=@regions[2][1]; @regions[2][1] = Region.new(self,current_x,current_y+2)
        @regions[0][2]=@regions[1][2];@regions[1][2]=@regions[2][2]; @regions[2][2] = Region.new(self,current_x+1,current_y+2)
      when :topleft
        # magic
      when :topright
        #more magic
      when :bottomleft
       #even more magic
      when :bottomright
       # last magic
      end
  end
  
  def create_region(world_x,world_y)
  
  end
  
  def update
    #placeholder
  end
  
  def remove
    Updatable::remove(self)
  end
end

class Region
  attr_accessor :width, :height, :x, :y, :map, :values, :elevation
  def initialize(world,x,y,width=10,height=10) #no region can exist without the world instance, duh. Also needs world coordinates.
    @world=world
    @x=x
    @y=y
    @elevation=@world.values[@y][@x]
    @width=width
    @height=height
    @values=Array.new(@height){Array.new(@width){0}}
    @map=Array.new(@height){Array.new(@width){0}}
    
    # First octave - we use the world map values as the foundation; using 6-th persistence (1/64)
      FractalNoise.octave(8, 6, @values, @world.values,  (1.0/64), [@x,@y], [false,false])
    #Second octave
      FractalNoise.octave(8, 7, @values, @world.noise, (1.0/128), [@x,@y], [false,false])
      FractalNoise.octave(8, 8, @values, @world.noise,  (1.0/256), [@x,@y], [false,false])    
    @world.boost_constract(@values)
    @map=@world.translate(@values)

  end
  
end