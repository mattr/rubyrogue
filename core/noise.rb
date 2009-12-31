require './core/misc'
include Math

module DiamondSquareNoise
  class << self; end
  
  def self.rando
    rand()-0.5
  end
  
  def self.go(times)
    arrays = [[0]]
    
    ratio = 2
    
    times.times do
      arrays.map! do |array|
        insert_nils(array)
      end
      arrays = insert_arrays(arrays)
      compute_from_diagonals(arrays) {|a, b, c, d| (a + b + c + d)/4 + rando*ratio} 
      compute_from_adjacents(arrays) {|a, b, c, d| (a + b + c + d)/4 + rando*ratio}
      ratio *= 0.5
    end
    
    return arrays
  end
  
  def self.insert_arrays(arrays)
    new_arrays = []
    arrays.size.times do |i|
      array = arrays[i]
      new_arrays.push array, Array.new(array.size, 0.0)
    end
    return new_arrays
  end
  
  def self.insert_nils(array)
    new_array = []
    array.size.times do |i|
      new_array.push(array[i], 0.0)
    end
    return new_array
  end
  
  def self.compute_from_adjacents(arrays)
    n = arrays.size
    n.times do |row|
      n.times do |column|
        next if (row + column) % 2 == 0
        arrays[row][column] = yield(
          arrays[(row-1) % n][column],
          arrays[row][(column-1) % n],
          arrays[row][(column+1) % n],
          arrays[(row+1) % n][column])
      end
    end
  end
  
  def self.compute_from_diagonals(arrays)
    n = arrays.size
    n.times do |row|
      next if row % 2 == 0
      n.times do |column|
        next if column % 2 == 0
        arrays[row][column] = yield(
          arrays[(row-1) % n][(column-1) % n],
          arrays[(row-1) % n][(column+1) % n],
          arrays[(row+1) % n][(column-1) % n],
          arrays[(row+1) % n][(column+1) % n])
      end
    end
  end
end
  
module FractalNoise
  def self.octave(octave, base, noise, persistence, offset=[0, 0], tilable=[true, true])
    return nil if persistence == 0
    
    base_height, base_width = base.length.to_f, base[0].length.to_f
    noise_height, noise_width = noise.length.to_f, noise[0].length.to_f
    
    # We want to slice base into pieces that are roughly square in shape.
    # Each of those squares will correspond to one cell in the noise array
    if base_height > base_width then # make 2**octave vertical cuts, then some greater number of horizontal cuts
      cuts_x = 2**octave
      slice_width = base_width/cuts_x
      cuts_y = (base_height/slice_width).ceil
      slice_height = base_height/cuts_y
    else # make 2**octave HORIZONTAL cuts, then some greater number of VERTICAL cuts
      cuts_y = 2**octave
      slice_height = base_height/cuts_y
      cuts_x = (base_width/slice_height).ceil
      slice_width = base_width/cuts_x
    end
    
    # Wrap around: either after as many steps as there are cuts, or after as many steps as possible.
    # That is, if tiling is necessary.
    wrap_x = tilable[0] ? [cuts_x, noise_width].min : noise_width
    wrap_y = tilable[1] ? [cuts_y, noise_height].min : noise_height
    
    base.length.times do |j|
      cy = offset[1]+j.to_f/slice_height # j/slice_height = what is the number of the slice j falls into
      coef_y = cy-cy.floor
      y0 = (cy.floor-1) % wrap_y
      y1 = cy.floor % wrap_y
      base[0].length.times do |i|
        cx = offset[0]+i.to_f/slice_width
        coef_x = cx-cx.floor
        x0 = (cx.floor-1) % wrap_x
        x1 = cx.floor % wrap_x
        top = lerp(noise[y0][x0], noise[y0][x1], coef_x)
        bottom = lerp(noise[y1][x0], noise[y1][x1], coef_x)
        base[j][i] += lerp(top, bottom, coef_y)*persistence
      end
    end
  end
end

module SimplexNoise
  class << self; attr_accessor :perm end
  F2=0.366025403 # F2=0.5*(sqrt(3.0)-1.0)
  G2=0.211324865 # G2=(3.0-sqrt(3.0))/6.0
  @perm=[]
  @grad=[
    [1, 1, 0], [-1, 1, 0], [1,-1, 0], [-1,-1, 0],
    [1, 0, 1], [-1, 0, 1], [1, 0,-1], [-1, 0,-1],
    [0, 1, 1], [ 0,-1, 1], [0, 1,-1], [ 0,-1,-1]
  ]
  
  #~ def self.floor(x)
    #~ return (x>0) ? (x.to_i) : (x.to_i-1)
  #~ end
  
  def self.dot(g, x, y) # get the gradient for point
    return g[0]*x + g[1]*y
  end
  
  def self.seed(seed)
    srand(seed)
    @perm = Array.new(256){rand(256)}
    @perm += @perm #double the array to make sure it doesn't get out of bounds
    srand
  end
  
  def self.noise(x, y)
    #skew input space to which simplex cell we are in
    s = (x+y)*F2
    i = (x+s).floor
    j = (y+s).floor
    
    t = (i+j)*G2
    x0 = i-t #unskew
    y0 = j-t
    x0 = x-x0 # x,y distances from cell origin
    y0 = y-y0
    
    #in 2D, simplex shape is equilateral triangle; determine simplex we're in
    if x0 > y0 then
      i1 = 1 #lower triangle, XY order: 0,0-> 1,0 -> 1,1
      j1 = 0
    else
      i1 = 0 #upper triangle, YX order: 0,0 -> 0,1 -> 1,1
      j1 = 1
    end
    
    # A step of (1,0) in (i,j) menas a step of (1-c,-c) in (x,y) and
    # a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
    #c = (3-sqrt(3))/6
    x1 = x0 - i1 + G2 #offsets for middle corner in (x,y), unskewed coordinates
    y1 = y0 - j1 + G2
    x2 = x0 - 1.0 + 2.0*G2 # offsets for last corner in (x,y) unskewed coords
    y2 = y0 - 1.0 + 2.0*G2
    
    #wrap the integer indices at 256, to avoid indexing perm[] out of bounds
    ii = i % 256
    jj = j % 256
    gi0 = @perm[ii+@perm[jj]]%12 #gradient indices
    gi1 = @perm[ii+i1+@perm[jj+j1]]%12
    gi2 = @perm[ii+1+@perm[jj+1]]%12
    
    #calculate the contribution of the three corners
    t0 = 0.5 - x0*x0 - y0*y0
    if t0 < 0.0 then
      n0 = 0.0
    else
      t0 *= t0
      n0 = t0*t0*dot(@grad[gi0], x0, y0)
    end
    t1 = 0.5 - x1*x1 - y1*y1
    if t1 < 0.0 then
      n1 = 0.0
    else
      t1 *= t1
      n1 = t1*t1*dot(@grad[gi1], x1, y1)
    end
    
    t2 = 0.5 - x2*x2 - y2*y2
    if t2 < 0.0 then
      n2 = 0.0
    else
      t2 *= t2
      n2 = t2*t2*dot(@grad[gi2], x2, y2)
    end
    
    #add contributions from corners to get final noise value
    #the result is scaled to [-1,1] range
    return 70.0*(n0 + n1 + n2)
  end
end