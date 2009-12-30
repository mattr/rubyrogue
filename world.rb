require 'cut'
require 'noise'
require 'gosu'
require 'handler'
require 'display'
require 'gradient'

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
  
  def translate(map,gradient=:color) #return an array of symbols and colors for display purposes
    array=Array.new(map.length){Array.new(map[0].length, 0)}
    steps=128
    case gradient
      when :color
        gradient=Gradient.new({
          0 => 0xFF0A054D,
          0.13 => 0xFF0A054D,
          0.29 => 0xFF4548F5,
          0.32 => 0xFFE5E74F,
          0.4 => 0xFF6EC453,
          0.45 => 0xFF6EC453,
          0.55 => 0xFF148D07,
          0.74 => 0xFF175A10,
          0.83 => 0xFF453413,
          0.93 => 0xFF31220C,
          0.99 => 0xFFFFFFFF,
          1 => 0xFFFFFFFF
        })
      when :greyscale
        gradient=Gradient.new({
          0 => 0xFF000000,
          1 => 0xFFFFFFFF
          })
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
    octaves.times{|i| FractalNoise.octave(i+1, @values, @noise, 1.0/2**(i+1), [0,0], [true,false])}
    
    boost_contrast(@values, 0.125, 0.875)
    @map = translate(@values)
    
    #populate the regions buffer at start
    @regions = [
      [Region.new(self, @width-1, @height-1), Region.new(self, 0, @height-1), Region.new(self, 1, @height-1)],
      [Region.new(self, @width-1, 0), Region.new(self, 0, 0), Region.new(self, 1, 0)],
      [Region.new(self, @width-1, 1), Region.new(self, 0, 1), Region.new(self, 1, 1)]
    ]
  end
  
  def change_region(direction)
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
  def initialize(world, x, y, width=8, height=8) #no region can exist without the world instance, duh. Also needs world coordinates.
    @world, @x, @y, @width, @height = world, x, y, width, height
    @values = Array.new(@height){|j| Array.new(@width, 0)}
    @map = Array.new(@height){Array.new(@width){0}}
    
    # First octave - we use the world map values as the foundation; using 6-th persistence (1/64)
      FractalNoise.octave(0, @values, @world.values, 1, [@x+0.5, @y+0.5], [false, false])
    #Second octave
      FractalNoise.octave(1, @values, @world.noise, 0.125, [@x*2, @y*2], [false, false])
      FractalNoise.octave(2, @values, @world.noise, 0.0625, [@x*4, @y*4], [false, false])
      FractalNoise.octave(3, @values, @world.noise, 0.03125, [@x*8, @y*8], [false, false])
    @map=@world.translate(@values)

  end
  
end

module Lighting
  
  def self.lightmap(values) #values = height map, lightmap = normals of each tile
    width=values[0].times
    height=values.times
    lightmap=Array.new(width){Array.new(height,0)}
    
    values.times do |j|
      values.times do |i|
        c=Vector[i,j,values[j][i]]
        a=Vector[i,j-1,values[j-1][i]]
        r=Vector[i+1,j,values[j][i+1]]
        lightmap[j][i]=normalize(cross(a-c,r-c)[2])
      end
    end
    
    return lightmap
  end
  
  def self.shade(normal,light)
    
  end
  
  def normalize(x)
    l = Math.sqrt(x[0]*x[0]+x[1]*x[1]+x[2]*x[2])
    Vector[x[0]/l,x[1]/l,x[2]/l]
  end
  
  def dot(x,y)
    Vector[x[0]*y[0], x[1]*y[1], x[2]*y[2]]
  end
  
  def cross(v,w)
    x=v[1]*w[2] - v[2]*w[1]
    y=v[2]*w[0] - v[0]*w[2]
    z=v[0]*w[1] - v[1]*w[0]
    Vector[x,y,z]
  end
end