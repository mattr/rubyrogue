require 'gosu'

def read_pgm(filename)
    array = IO.readlines(filename)
    header = []
    while header.length < 3 do
      line = array.shift.chomp
      header << line unless line =~ /\A\s*#/
    end
    raise "Wrong file type: #{header[0]} instead of P2" unless header[0] == 'P2'
    width, height = header[1].split(/\s+/).collect{|t| t.to_i}
    max_value = header[2].to_i
    raw = array.join.split(/\s+/).collect{|t| t.to_i}
    unless max_value == 255 then
      d = (max_value+1)/256
      raw.collect!{|v| v/d} # scales everything into the 0..255 integer range
    end
    matrix = []
    height.times do |y|
      matrix << raw[y*width, width]
    end
    return matrix
  end
    
  #  heightmap=read_pgm('./images/world.pgm')