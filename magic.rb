module Visible
  @visible_classes = []
  
  def self.extended(base)
    @visible_classes << base
  end
  
  def self.draw
    @visible_classes.each do |c|
      c.instances.each{|obj| obj.draw}
    end
  end
end

class Listable
  def self.init_instances
    puts inspect
    @instances = []
    class << self
      attr_accessor :instances
    end
  end
  
  def self.inherited(subclass)
    subclass.init_instances
  end
  
  def self.new(*args)
    tmp = super
    @instances << tmp
    return tmp
  end
end

class TextInput < Listable
  extend Visible # ensures that this object's draw() method is called every tick
  
  def initialize(default)
    @default = default
    yield if block_given?
  end
  
  def draw
    puts @default
  end
end

class GameWindow
  def draw
    Visible::draw
  end
end

g = GameWindow.new
g.draw

puts '-------'
t1 = TextInput.new('one')
t2 = TextInput.new('two')
g.draw

puts '-------'
t3 = TextInput.new('three')
t4 = TextInput.new('four')
g.draw
