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
				value=(value+1)*0.5
				#Convert noise
        if value < 0 then @map[i][j]=[:' ',0xFF000000]
        elsif value > 0 and value <= 0.2 then @map[i][j]=[:fill100,0xFF333333]
        elsif value > 0.2 and value <= 0.4 then @map[i][j]=[:fill100,0xFF666666]
        elsif value > 0.4 and value <= 0.6 then @map[i][j]=[:fill100, 0xFF999999]
        elsif value > 0.6 and value <=0.8 then @map[i][j]=[:fill100,0xFFCCCCCC]
        else @map[i][j]=[:fill100,0xFFFFFFFF] end
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