require 'cut'
require 'noise'
require 'handler'
require 'gosu'

class World
	include Updatable
	# Builds and manages game areas and locations
	# Order of scale: World > Region > Area > Tile/Node
	attr_accessor :width, :height, :seed, :map
	@width=16
	@height=16
	@seed=0
	@map=[]
	
	def initialize(width=16,height=16,seed=0)
		@width=width
		@height=height
		@seed=seed
		@map=Array.new(@width){Array.new(@height){0}}
		SimplexNoise.seed(@seed)
    # load values
		@width.times do |i|
			@height.times do |j|
				# Octave 1: Grain
				value=(SimplexNoise.noise(i*2,j*2)+1)*20
        value=(value-value.to_i)
				# Octave 2: Fine noise
				value+=SimplexNoise.noise(i*200,j*200)*0.5
				# Octave 3: Streak
				value+=SimplexNoise.noise(i,j*100)*0.7
				#Adjust range to [0,1]
				value=value/6+0.5
        @map[i][j]=value
			end
		end
    # boost contrast
    base_min = @map.collect{|row| row.min}.min
    base_max = @map.collect{|row| row.max}.max
    @map.each{|row| row.collect!{|cell| (cell-base_min)/(base_max-base_min)}}
    # actually make it a map
    @width.times do |i|
			@height.times do |j|
        shade = (255*@map[i][j]).to_i
        @map[i][j] = [:fill100, Gosu::Color.new(shade, shade, shade)]
			end
		end
    
	end
	
	def update
		#placeholder
	end
	
	def remove
		Updatable::remove(self)
	end
end