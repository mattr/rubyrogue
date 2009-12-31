require 'gosu'

class Gradient
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
    return Gosu::Color.new(a, r, g, b)
  end
end