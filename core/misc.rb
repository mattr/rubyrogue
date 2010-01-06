# Various useful snippets

class Object
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

  def clamp(min, value, max)
    return (min>value ? min : (value>max ? max : value))
  end
  
  def lerp(x, y, a)
    return (1-a)*x + a*y
  end
  
  def constrast_boost(base, min=0, max=1) #rescale everything to (0, max) range
    base_min = base.collect{|row| row.min}.min
    base_max = base.collect{|row| row.max}.max
    base.each{|row| row.collect!{|cell| min+(max-min)*(cell-base_min)/(base_max-base_min)}}
  end

end

class BitField
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

