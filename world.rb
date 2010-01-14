class World
  include Updatable
  attr_accessor :width, :height, :seed, :noise, :raw, :regions, :map
  
  def initialize(type=:random,width=DEFAULT_WORLD_SIZE[0],height=DEFAULT_WORLD_SIZE[1], seed=DEFAULT_SEED)
    @width,@height,@seed=width,height,seed
    @virtual_world_size=[@width*DEFAULT_REGION_SIZE[0],@height*DEFAULT_REGION_SIZE[1]]
    
    yield 'Starting world generation...' if block_given?
    # First stage: Create noise map
    srand(@seed)
    @noise=Array.new(@height){Array.new(@width){rand}} # For now, just fill it with random numbers)
    srand
    yield 'Noise map created.' if block_given?
    
    # Second stage: Generate height map
    case type # the switch prepares @raw array
      when :flat #simply create a flat world
        @raw=Array.new(@height){Array.new(@width,0.6)}
      when :random # do a few octaves of Perlin noise for the world map
        @raw = Array.new(@height){Array.new(@width){0.5}}
        octaves = (Math.log([@width, @height].max)/Math.log(2)).to_i
        octaves.times{|i| FractalNoise.octave(i+1, @raw, @noise, 1.0/2**(i+1), [0,0], [true, false])}
        constrast_boost(@raw)
      when :file
        #placeholder, should load heighmap and use it as the basic for world map
      end
    constrast_boost(@raw)
    yield 'Height map generated.' if block_given?
      
    # Third stage: Create displayable map
    @map=Array.new(@height){Array.new(@width){[nil,[nil,nil]]}}
    translate_world_map(:color)
    yield 'Simple world map created.' if block_given?

    # Fourth stage: Create regions
    @regions=Array.new(@height){Array.new(@width){nil}}
    @height.times do |y|
      @width.times do |x|
        @regions[y][x]=Region.new(self,x,y)
        yield 'Region '+x.to_s+'x'+y.to_s+' created.' if block_given?
      end
    end
    yield 'Regions created.' if block_given?
    
    # Fifth stage: Finalize, may add more steps.
    yield 'World generation completed.' if block_given?
  end
  
  def translate_world_map(gradient=:color)
    case gradient
      when :color
        gradient=GRADIENT_COLOR_MAP
      when :grayscale
        gradient=GRADIENT_GREYSCALE
    end
    
    @height.times do |j|
      @width.times do |i|
        @map[j][i][MAP_VISIBLE]=[:fill,gradient.color(@raw[j][i])]
      end
    end
  end
  
  def [](y,x)
    if y > @virtual_world_size[1]-1 or y < 0 then return nil end #the world doesn't wrap vertically
    x = x % @virtual_world_size[0] # the world wraps horizontally
    return @regions[y/DEFAULT_REGION_SIZE[1]][x/DEFAULT_REGION_SIZE[0]][y % DEFAULT_REGION_SIZE[1], x % DEFAULT_REGION_SIZE[0]]
  end

  def update
    # placeholder
  end
  
  def remove
    Updatable::remove(self)
  end

end

class Region
  attr_accessor :x, :y, :width, :height, :elevation, :map, :raw, :entities, :locals, :visible, :changed, :file
  
  def initialize(world, x, y)
    @world, @x, @y=world, x, y
    @width, @height = DEFAULT_REGION_SIZE[0], DEFAULT_REGION_SIZE[1]
    @file="./data/world/region_"+@x.to_s+"_"+@y.to_s+".map" # unique file name
    @elevation = @world.raw[y][x] # remember the region's elevation level on world
    @entities = {} # hash containing entities present in the region
    @locals = {} # hash containing unique locations in the region
    @visible = false #  the region's maps are not loaded
    @changed = false # set this flag to true for the map to be saved again (to write changes such as terrain modification)
    #At some point, implement biomes and stuff here
    
    create_map
    dump_map
    @visible = false
  end
  
  def create_map #generate @raw and then create @map
    raw=Array.new(@height){Array.new(@width){@elevation}}
    # First octave, take the world's height map as guide
    FractalNoise.octave(0, raw, @world.raw, 1, [@x+0.5, @y+0.5], [false, false])
    # Other octaves, detail using the world's cached noise
    FractalNoise.octave(1, raw, @world.noise, 0.0625, [@x*2, @y*2], [false, false])
    FractalNoise.octave(2, raw, @world.noise, 0.03125, [@x*4, @y*4], [false, false])
    FractalNoise.octave(3, raw, @world.noise, 0.015625, [@x*8, @y*8], [false, false])
    
    @map=Array.new(@height){Array.new(@width){[nil,nil,nil,nil,nil,nil,nil,nil,nil,nil]}}
    @height.times do |j|
      @width.times do |i|
        @map[j][i][MAP_HEIGHT]=raw[j][i]
        @map[j][i][MAP_VISIBLE]=[:fill,GRADIENT_COLOR_MAP.color(raw[j][i])]
      end
    end
  end
  
  def [](y,x)
    if not @visible then
      load_map
      @visible=true
    end
    return @map[y][x]
  end
  
  def dump_map # save the map to file
    File.open(@file,'w+') do |file|
      Marshal.dump(@map, file)
    end
  end
  
  def load_map # load the map from file
    File.open(@file,'r+') do |file|
      @map=Marshal.load(file)
    end
    @visible = true
  end
  
  def close_map # clear the map, to conserve the memory, but dump it first if any changes were made
    if @changed then
      dump_map
      @changed = false
    end
    @map = nil
    @visible = false
  end  
end

class Local


end