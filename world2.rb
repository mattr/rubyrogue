# World map rewrite, NOT YET IMPLEMENTED

class World
  include Updatable
  
  def initialize(seed=WORLD_SEED)
    @seed = seed
    @world_width = WORLD_SIZE[0] * REGION_SIZE[0] #virtual world size
    @world_height = WORLD_SIZE[1] * REGION_SIZE[1]
    @noise = Array.new
    
    
  end
  
  def [](x,y)
    if y > @world_height-1 or y < 0 then return nil end #the world doesn't wrap vertically
    x = x % @world_width # the world wraps horizontally
    return @regions[ y / REGION_SIZE[1] ][ x / REGION_SIZE[0] ][x % REGION_SIZE[0], y % REGION_SIZE[1]]
  end
  
end