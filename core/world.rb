# world.rb

class World
  include Updatable
  # Builds and manages game areas and locations
  # Order of scale: World > Region > Area > Tile/Node
  attr_accessor :width, :height, :seed, :map, :values, :regions, :noise, :heightmap
  @values = [] #processed fractal noise
  @map = [] #world map converted from noise
  @heightmap= []

  
  def initialize(width=DEFAULT_WORLD_SIZE[0], height=DEFAULT_WORLD_SIZE[1], seed=DEFAULT_SEED)
    @width, @height, @seed = width, height, seed
    @regions=[[0,0,0],[0,0,0],[0,0,0]] # 3x3 array of preloaded regions; current region is always [1][1]
    create_world()
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
  
  def boost_contrast(base, min=0, max=1) #rescale everything to (0, max) range
    base_min = base.collect{|row| row.min}.min
    base_max = base.collect{|row| row.max}.max
    base.each{|row| row.collect!{|cell| min+(max-min)*(cell-base_min)/(base_max-base_min)}}
  end
  
  def create_world() #create the world map
    srand(@seed)
    @noise = Array.new(@height){Array.new(@width){rand-0.5}} # intitial noise
    srand
    @values = Array.new(@height){Array.new(@width, 0.5)}
    octaves = (Math.log([@width, @height].max)/Math.log(2)).to_i
    #~ octaves = 3
    octaves.times{|i| FractalNoise.octave(i+1, @values, @noise, 1.0/2**(i+1), [0,0], [true, false])}
    
    boost_contrast(@values)
    @map = translate(@values)
    @heightmap = translate(@values,:grayscale)
    #~ @lightmap=Lighting.lightmap(@values)
end
  
  def update_regions(x=0,y=0) #load regions at given world coordinates
    @regions = [
      [Region.new(self, x-1, y-1), Region.new(self, x, y-1), Region.new(self, x+1, y-1)],
      [Region.new(self, x-1, y), Region.new(self, x, y), Region.new(self, x+1, y)],
      [Region.new(self, x-1, y+1), Region.new(self, x, y+1), Region.new(self, x+1, y+1)]
    ]
  end
  
  def change_region(direction) #transition between adjacent regions
    current_x=@regions[1][1].x
    current_y=@regions[1][1].y
    case direction
      when :left
        #shift array right, create three left cells
        3.times do |i|
          @regions[i].pop
          @regions[i].unshift(Region.new(self, current_x-2, current_y-1+i))
        end
      when :right
        #shift array left, create three right cells
        3.times do |i|
          @regions[i].shift
          @regions[i].push(Region.new(self, current_x+2, current_y-1+i))
        end
      when :up
        #shift array down, create three top cells
        @regions.pop
        @regions.unshift([Region.new(self, current_x-1, current_y-2), Region.new(self, current_x, current_y-2), Region.new(self, current_x+1, current_y-2)])
      when :down
        #shift array up, create three bottom cells
        @regions.shift
        @regions.push([Region.new(self, current_x-1, current_y+2), Region.new(self, current_x, current_y+2), Region.new(self, current_x+1, current_y+2)])
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
  
  def update
    #placeholder
  end
  
  def remove
    Updatable::remove(self)
  end
end

class Region
  attr_accessor :width, :height, :x, :y, :map, :values, :elevation, :lightmap, :passable
  def initialize(world, x, y, width=8, height=8) #no region can exist without the world instance, duh. Also needs world coordinates.
    @world, @x, @y, @width, @height = world, x, y, width, height
    @x=@x%@world.width # wrap x-axis
  
    fractal_region()
    if @y>0 and @y<@world.height-1 then
      @passable=true #non-polar regions are passable
    else
      @passable=false #polar regions are passable
    end
  end
  
  def fractal_region() #an actual region
    @values = Array.new(@height){Array.new(@width, 0)}
    @map = Array.new(@height){Array.new(@width){0}}
    # First octave
      FractalNoise.octave(0, @values, @world.values, 1, [@x+0.5, @y+0.5], [false, false])
    #Second octaves
      FractalNoise.octave(1, @values, @world.noise, 0.0625, [@x*2, @y*2], [false, false])
      FractalNoise.octave(2, @values, @world.noise, 0.03125, [@x*4, @y*4], [false, false])
      FractalNoise.octave(3, @values, @world.noise, 0.015625, [@x*8, @y*8], [false, false])
    @map=@world.translate(@values)
  end
end