# world.rb

class World
  include Updatable
  # Builds and manages game areas and locations
  # Order of scale: World > Region > Area > Tile/Node
  attr_accessor :width, :height, :seed, :map, :raw, :regions, :noise, :x, :y
  @raw = [] # pure height values, scaled to 0.0 - 1.0
  @map = [] #world map converted from noise
  @x=@y=0 # current world coordinates

  
  def initialize(random_map=true, width=DEFAULT_WORLD_SIZE[0], height=DEFAULT_WORLD_SIZE[1], seed=DEFAULT_SEED)
    @width, @height, @seed = width, height, seed
    @regions=[[nil,nil,nil],[nil,nil,nil],[nil,nil,nil]] # 3x3 array of preloaded regions; current region is always [1][1]
    case random_map
      when :random
        random_world() #create a random world
      when :file
        load_world() #load the world from file
      when :flat
        flat_world() # placeholder world for testing purposes
    end
  end
  
  def translate(map,gradient=:color) #return an array of symbols and colors for display purposes
    array=Array.new(map.length){Array.new(map[0].length, 0)}
    case gradient
      when :color
        gradient=GRADIENT_COLOR_MAP
      when :grayscale
        gradient=GRADIENT_GREYSCALE
    end
    
    map.length.times do |j|
      map[j].length.times do |i|
        array[j][i]=[:fill,gradient.color(map[j][i])]
      end
    end
    return array
  end
  
  def random_world() #create the world map procedurally
    srand(@seed)
    @noise = Array.new(@height){Array.new(@width){rand-0.5}} # intitial noise
    srand
    @raw = Array.new(@height){Array.new(@width){0.5}}
    octaves = (Math.log([@width, @height].max)/Math.log(2)).to_i
    #~ octaves = 3
    octaves.times{|i| FractalNoise.octave(i+1, @raw, @noise, 1.0/2**(i+1), [0,0], [true, false])}
    
    constrast_boost(@raw)
    @map = translate(@raw)
  end
  
  def load_world()
    srand(@seed)
    # still generate the noise for use by regions
    @noise = Array.new(@height){Array.new(@width){rand-0.5}}
    srand
    File.open('olimea.raw','r+') do |file|
      @raw = Marshal.load(file) # the file contents should already be scaled to 0..1 !
    end
    @map = translate(@raw)    
  end
  
  def flat_world()
    @noise=[[0.55]*@width]*@height
    @raw=@noise.dup
    @map=translate(@raw)
  end
  
  def update_regions(x=0,y=0) #load regions at given world coordinates
    @regions = [
      [Region.new(self, x-1, y-1), Region.new(self, x, y-1), Region.new(self, x+1, y-1)],
      [Region.new(self, x-1, y), Region.new(self, x, y), Region.new(self, x+1, y)],
      [Region.new(self, x-1, y+1), Region.new(self, x, y+1), Region.new(self, x+1, y+1)]
    ]
    @x,@y=x,y
  end
  
  def move(direction) #transition between adjacent regions
    current_x=@regions[1][1].x
    current_y=@regions[1][1].y
    if direction==:left then
        #shift array right, create three left cells
        3.times do |i|
          @regions[i].pop
          @regions[i].unshift(Region.new(self, current_x-2, current_y-1+i))
        end
        @x,@y=@regions[1][1].x,@regions[1][1].y
    elsif direction==:right then
      #shift array left, create three right cells
      3.times do |i|
        @regions[i].shift
        @regions[i].push(Region.new(self, current_x+2, current_y-1+i))
      end
      @x,@y=@regions[1][1].x,@regions[1][1].y
    elsif direction==:up  then
        #shift array down, create three top cells
        @regions.pop
        @regions.unshift([Region.new(self, current_x-1, current_y-2), Region.new(self, current_x, current_y-2), Region.new(self, current_x+1, current_y-2)])
        @x,@y=@regions[1][1].x,@regions[1][1].y
    else # direction==:down
        #shift array up, create three bottom cells
        @regions.shift
        @regions.push([Region.new(self, current_x-1, current_y+2), Region.new(self, current_x, current_y+2), Region.new(self, current_x+1, current_y+2)])
        @x,@y=@regions[1][1].x,@regions[1][1].y
    end
  end
  
  def update
    #placeholder
  end
  
  def remove
    Updatable::remove(self)
  end
  
  def region_left
    return @regions[1][0]
  end
  
  def region_right
    return @regions[1][2]
  end
  
  def region_up
    return @regions[0][1]
  end
  
  def region_down
    return @regions[2][1]
  end
  
  def region_current
    return @regions[1][1]
  end
  
end

class Region
  attr_accessor :width, :height, :x, :y, :map, :raw, :elevation, :lightmap, :passable
  def initialize(world, x, y, width=32, height=32) #no region can exist without the world instance, duh. Also needs world coordinates.
    @world, @x, @y, @width, @height = world, x, y, width, height
    @x=@x%@world.width # wrap x-axis
  
    create()
    if @y>0 and @y<@world.height-1 then
      @passable=true #non-polar regions are passable
    else
      @passable=false #polar regions are passable
    end
  end
  
  def create() #create the region
    @raw = Array.new(@height){Array.new(@width,0)}
    @map = []
    # First octave
      FractalNoise.octave(0, @raw, @world.raw, 1, [@x+0.5, @y+0.5], [false, false])
    #Second octaves
      FractalNoise.octave(1, @raw, @world.noise, 0.0625, [@x*2, @y*2], [false, false])
      FractalNoise.octave(2, @raw, @world.noise, 0.03125, [@x*4, @y*4], [false, false])
      FractalNoise.octave(3, @raw, @world.noise, 0.015625, [@x*8, @y*8], [false, false])
    @map=@world.translate(@raw)
  end
end