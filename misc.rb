# Various useful snippets - here is the list:
# rand(*args) now accepts arrays, ranges or multiple arguments
# clamp(min, value, max)
# lerp(x, y, a)
# constrast_boost(base,min,max)
# bresenham_line(x0,y0,x1,y1)
# Bitfield class (methods: []=, [], .to_s, .total_set, .clear)
# ShadowcastingFieldOfView module
# Gradient class; usage: gradient=Gradient.new(Array, hash or multiple colors) and gradient.color(point, total)

class Object
  # start of custom methods
  @@old_rand = Kernel.method(:rand)
  def rand(*args)
    if args.length>1 then
      return args[@@old_rand.call(args.length)]
    elsif args[0].kind_of?(Array) then
      return args[0][@@old_rand.call(args[0].length)]
    elsif args[0].kind_of?(Range) then
      return @@old_rand.call(args[0].end-args[0].begin+(args[0].exclude_end? ? 0 : 1))+args[0].begin
    else
      @@old_rand.call(*args)
    end
  end
  
  # clamp value min < value < max
  def clamp(min, value, max)
    return (min>value ? min : (value>max ? max : value))
  end
  
  # Linear interpolation
  def lerp(x, y, a)
    return (1-a)*x + a*y
  end
  
  # constrast boost (note: alters the base array)
  def constrast_boost(base, min=0, max=1) #rescale everything to (0, max) range
    base_min = base.collect{|row| row.min}.min
    base_max = base.collect{|row| row.max}.max
    base.each{|row| row.collect!{|cell| min+(max-min)*(cell-base_min)/(base_max-base_min)}}
  end
  
  # Bresenham line algorithm
  def bresenham_line(x0,y0,x1,y1)
    points = []
    steep = ((y1-y0).abs) > ((x1-x0).abs)
    if steep
      x0,y0 = y0,x0
      x1,y1 = y1,x1
    end
    if x0 > x1
      x0,x1 = x1,x0
      y0,y1 = y1,y0
    end
    deltax = x1-x0
    deltay = (y1-y0).abs
    error = (deltax / 2).to_i
    y = y0
    ystep = nil
    if y0 < y1
      ystep = 1
    else
      ystep = -1
    end
    for x in x0..x1
      if steep
        points << {:x => y, :y => x}
      else
        points << {:x => x, :y => y}
      end
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end
    return points
  end
  
end #end of Object

class BitField #bitfield
  #        NAME: BitField
  #      AUTHOR: Peter Cooper
  #     LICENSE: MIT ( http://www.opensource.org/licenses/mit-license.php )
  #   COPYRIGHT: (c) 2007 Peter Cooper (http://www.petercooper.co.uk/)
  #     VERSION: v4
  #     HISTORY: v4 (fixed bug where setting 0 bits to 0 caused a set to 1)
  #              v3 (supports dynamic bitwidths for array elements.. now doing 32 bit widths default)
  #              v2 (now uses 1 << y, rather than 2 ** y .. it's 21.8 times faster!)
  #              v1 (first release)
  #
  # DESCRIPTION: Basic, pure Ruby bit field. Pretty fast (for what it is) and memory efficient.
  #              I've written a pretty intensive test suite for it and it passes great. 
  #              Works well for Bloom filters (the reason I wrote it).
  #
  #              Create a bit field 1000 bits wide
  #                bf = Bitfield.new(1000)
  #
  #              Setting and reading bits
  #                bf[100] = 1
  #                bf[100]    .. => 1
  #                bf[100] = 0
  #
  #              More
  #                bf.to_s = "10101000101010101"  (example)
  #                bf.total_set         .. => 10  (example - 10 bits are set to "1")
  attr_reader :size, :field
  include Enumerable
  
  ELEMENT_WIDTH = 32
  
  def initialize(size)
    @size = size
    @field = Array.new(((size - 1) / ELEMENT_WIDTH) + 1, 0)
  end
  
  # Set a bit (1/0)
  def []=(position, value)
    if value == 1
      @field[position / ELEMENT_WIDTH] |= 1 << (position % ELEMENT_WIDTH)
    elsif (@field[position / ELEMENT_WIDTH]) & (1 << (position % ELEMENT_WIDTH)) != 0
      @field[position / ELEMENT_WIDTH] ^= 1 << (position % ELEMENT_WIDTH)
    end
  end
  
  # Read a bit (1/0)
  def [](position)
    @field[position / ELEMENT_WIDTH] & 1 << (position % ELEMENT_WIDTH) > 0 ? 1 : 0
  end
  
  # Iterate over each bit
  def each(&block)
    @size.times { |position| yield self[position] }
  end
  
  # Returns the field as a string like "0101010100111100," etc.
  def to_s
    inject("") { |a, b| a + b.to_s }
  end
  
  # Clears the bitfield. More efficient than using Bitfield#each
  def clear
    @field.each_index { |i| @field[i] = 0 }
  end
  
  # Returns the total number of bits that are set
  # (The technique used here is about 6 times faster than using each or inject direct on the bitfield)
  def total_set
    @field.inject(0) { |a, byte| a += byte & 1 and byte >>= 1 until byte == 0; a }
  end
end

# Shadowcasting FoV algirithm, include in map class and use do_fov
# needs the following methods provided: blocked?(x,y) for obstacles and light(x,y) to set the light at coords
module ShadowcastingFOV
    # Multipliers for transforming coordinates into other octants
    @@mult = [
                [1,  0,  0, -1, -1,  0,  0,  1],
                [0,  1, -1,  0,  0, -1,  1,  0],
                [0,  1,  1,  0,  0, -1, -1,  0],
                [1,  0,  0,  1, -1,  0,  0, -1],
             ] 

    # Determines which co-ordinates on a 2D grid are visible
    # from a particular co-ordinate.
    # start_x, start_y: center of view
    # radius: how far field of view extends
    def do_fov(start_x, start_y, radius)
        light start_x, start_y
        8.times do |oct|
            cast_light start_x, start_y, 1, 1.0, 0.0, radius,
                @@mult[0][oct],@@mult[1][oct],
                @@mult[2][oct], @@mult[3][oct], 0
        end
    end
    
    private
    # Recursive light-casting function
    def cast_light(cx, cy, row, light_start, light_end, radius, xx, xy, yx, yy, id)
        return if light_start < light_end
        radius_sq = radius * radius
        (row..radius).each do |j| # .. is inclusive
            dx, dy = -j - 1, -j
            blocked = false
            while dx <= 0
                dx += 1
                # Translate the dx, dy co-ordinates into map co-ordinates
                mx, my = cx + dx * xx + dy * xy, cy + dx * yx + dy * yy
                # l_slope and r_slope store the slopes of the left and right
                # extremities of the square we're considering:
                l_slope, r_slope = (dx-0.5)/(dy+0.5), (dx+0.5)/(dy-0.5)
                if light_start < r_slope
                    next
                elsif light_end > l_slope
                    break
                else
                    # Our light beam is touching this square; light it
                    light(mx, my) if (dx*dx + dy*dy) < radius_sq
                    if blocked
                        # We've scanning a row of blocked squares
                        if blocked?(mx, my)
                            new_start = r_slope
                            next
                        else
                            blocked = false
                            light_start = new_start
                        end
                    else
                        if blocked?(mx, my) and j < radius
                            # This is a blocking square, start a child scan
                            blocked = true
                            cast_light(cx, cy, j+1, light_start, l_slope,
                                radius, xx, xy, yx, yy, id+1)
                            new_start = r_slope
                        end
                    end
                end
            end # while dx <= 0
            break if blocked
        end # (row..radius+1).each
    end
end


class Gradient # 
  def self.binary_search(lst, target)
    return search_iter(lst, 0, lst.length-1, target)
  end
   
  def self.search_iter(lst, lower, upper, target)
    return [lst[lower], lst[upper]] if lower+1 == upper
    mid = (lower+upper)/2
    
    if (target == lst[mid])
      return [lst[mid], lst[mid]]
    elsif (target < lst[mid])
      return search_iter(lst, lower, mid, target)
    else
      return search_iter(lst, mid, upper, target)
    end
  end
  
  def initialize(*args)
    @color_hash = {}
    if args.length>1 then
      args.each_index{|i| @color_hash[i.to_f/(args.length-1)] = args[i]}
    elsif args[0].kind_of?(Array) # array of length 1 will cause division by 0 error
      args[0].each_index{|i| @color_hash[i.to_f/(args[0].length-1)] = args[0][i]}
    elsif args[0].kind_of?(Hash)
      @color_hash = args[0]
    else
      @color_hash = {0.0 => arg[0], 1.0 => arg[0]}
    end
    @color_hash.each{|k, v| @color_hash[k] = v.kind_of?(Gosu::Color) ? v : Gosu::Color.new(v)}
    @color_hash_keys = @color_hash.keys.sort
  end
  
  def color(i, total = 0)
    spot = (total != 0) ? (i.to_f/total) : i.to_f
    pair = Gradient.binary_search(@color_hash_keys, spot)
    return @color_hash[pair[0]] if pair[1] == pair[0]
    k = (spot-pair[0])/(pair[1]-pair[0])
    a = ((1-k)*@color_hash[pair[0]].alpha+k*@color_hash[pair[1]].alpha).to_i
    r = ((1-k)*@color_hash[pair[0]].red+k*@color_hash[pair[1]].red).to_i
    g = ((1-k)*@color_hash[pair[0]].green+k*@color_hash[pair[1]].green).to_i
    b = ((1-k)*@color_hash[pair[0]].blue+k*@color_hash[pair[1]].blue).to_i
    return (a << 24) + (r << 16) + (g << 8) + b
  end
end