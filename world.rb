require 'cut'
require 'noise'
require 'handler'
require 'gosu'

class World
	include Updatable
	# Builds and manages game areas and locations
	# Order of scale: World > Region > Area > Tile/Node
	attr_accessor :width, :height, :seed, :map, :global
	@width=16
	@height=16
	@seed=0
	@global=[] #processed fractal noise
  @map=[] #world map converted from noise
	
	def initialize(width=16,height=16,seed=0)
		@width=width
		@height=height
		@seed=seed
    create_world()
    # load values
    
	end
  
  def translate(map) #return an array of symbols and colors for display purposes
    array=Array.new(map.length){Array.new(map[0].length,0)}
    map.length.times do |i|
      map[i].length.times do |j|
        shade=((255*map[i][j]).to_i)
        array[i][j]=[:fill100, Gosu::Color.new(shade,shade,shade)]
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
    noise=Array.new(@width){Array.new(@height){rand}} # intitial noise
    srand
    @global=Array.new(@width){Array.new(@height,0.0)}
    # First octave
    FractalNoise.octave(3,1,@global,noise,@width,@height,0.5,[0,0])
    #Second octave
    FractalNoise.octave(3,2,@global,noise,@width,@height,0.25,[0,0])
    #Third octave
    #~ FractalNoise.octave(3,3,@global,noise,@width,@height,0.125,[0,0])
    
    boost_constract(@global)
    @map=translate(@global)
  end
	
	def update
		#placeholder
	end
	
	def remove
		Updatable::remove(self)
	end
end