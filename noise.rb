module Noise
	attr_accessor :width, :height, :seed, :persistance, :amplitude, :base_noise
	#change these values
	@width = 8
	@height = 8
	@seed = 1
	@persistance=0.5
	@amplitude=1.0
	@octaves=8
	@base_noise=Array.new(@width){Array.new(@height,0)}

	def self.uniform_noise()
		@width.times do |i|
			@height.times do |j|
				@base_noise[i][j]=rand
			end
		end
	end
	
	def self.generate_noise(base_noise,k)
		sample_period = 2**k
		sample_frequency = 1.0/sample_period
		smooth=Array.new(@width){Array.new(@height,0)}
		
		@width.times do |i|
			sample_i0 = (i >> k) << k
			sample_i1 = sample_i0  % @width
			horizontal_blend = (i-sample_i0)*sample_frequency
			@height.times do |j|
				sample_j0 = ( j >> k) << k
				sample_j1 = (sample_j0+1) % @height
				vertical_blend = (j - sample_j0)*sample_frequency
				top=interpolate(@base_noise[sample_i0][sample_j0],@base_noise[sample_i1][sample_j1],horizontal_blend)
				bottom=interpolate(@base_noise[sample_i0][sample_j0],@base_noise[sample_i1][sample_j1],vertical_blend)
				smooth[i][j]=interpolate(top,bottom,vertical_blend)
			end
		end
		return smooth
	end
	
	def self.interpolate(x0,x1,alpha)
		return (1-alpha)*x0 + alpha*x1
	end
	
	def self.generate_perlin(octaves=@octaves,base=@base_noise)
		smooth=[]

		#generate noises
		octaves.times do |k| 
			smooth[k]=generate_noise(base,k)
		end
		
		persistance = @persistance
		amplitude=@amplitude
		total_amplitude=0
		perlin=Array.new(@width){Array.new(@height, 0)}
		#blend noises
		octaves.times do |k|
			amplitude*=persistance
			total_amplitude+=amplitude
			@width.times do |i|
				@height.times do |j|
					perlin[i][j]+=smooth[k][i][j]*amplitude
				end
			end
		end
		#normalization
		@width.times do |i| 
			@height.times do |j| perlin[i][j]/=total_amplitude end
			end
		return perlin
	end
end

Noise.uniform_noise()
noise=Noise.generate_perlin()
puts noise.inspect