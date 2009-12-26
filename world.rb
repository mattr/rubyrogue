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
	
	def initialize(size=4,seed=0)
		@width=width
		@height=height
		@seed=seed
    @map=DiamondSquareNoise.go(size)
    # load values

    # boost contrast
    base_min = @map.collect{|row| row.min}.min
    base_max = @map.collect{|row| row.max}.max
    @map.each{|row| row.collect!{|cell| (cell-base_min)/(base_max-base_min)}}
    # actually make it a map
    @map.length.times do |i|
			@map[0].length.times do |j|
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