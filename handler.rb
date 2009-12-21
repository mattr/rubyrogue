module Sorted # this is an inefficient implementation (n^2 rather than log(n)), but it works
  DEFAULT_PREDICATE = Proc.new{|x, y| x[1] <=> y[1]}

  def self.insert(array, object, &block)
    array << object
    relocate(array, object, &block)
  end
  
  def self.relocate(array, object, &block)
    sort_predicate = block || DEFAULT_PREDICATE
    array.sort!(&sort_predicate)
  end
end

module Drawable
  DEFAULT_PRIORITY = 0

  class << self; attr_accessor :instances end
  @instances = []
  
  def self.do!
    @instances.each{|pair| pair[0].draw}
  end
  
  def self.remove(obj)
    instances.delete([obj, obj.draw_priority]) # this is also suboptimal (O(n) rather than log(n))
  end
  
  def draw_priority
    return @draw_priority || DEFAULT_PRIORITY
  end
  
  def draw_priority=(arg)
    Drawable::instances.delete([self, self.draw_priority]) # this is also suboptimal (O(n) rather than log(n))
    @draw_priority = arg
    Sorted::insert(Drawable::instances, [self, arg])
  end
  
  def self.included(base)
    class << base
      alias :drawable_old_new new
      def new(*args, &block)
        instance = drawable_old_new(*args, &block) # rather than super, since the extending class could have non-trivial new method
        Sorted::insert(Drawable::instances, [instance, DEFAULT_PRIORITY])
        return instance
      end
    end
  end
end

module Updatable
  DEFAULT_PRIORITY = 0

  class << self; attr_accessor :instances end
  @instances = []
  
  def self.do!
    @instances.each{|pair| pair[0].update}
  end
  
  def self.remove(obj)
    instances.delete([obj, obj.update_priority]) # this is also suboptimal (O(n) rather than log(n))
  end
  
  def update_priority
    return @update_priority || DEFAULT_PRIORITY
  end
  
  def update_priority=(arg)
    Updatable::instances.delete([self, self.update_priority]) # this is also suboptimal (O(n) rather than log(n))
    @update_priority = arg
    Sorted::insert(Updatable::instances, [self, arg])
  end
  
  def self.included(base)
    class << base
      alias :updatable_old_new new
      def new(*args, &block)
        instance = updatable_old_new(*args, &block) # rather than super, since the extending class could have non-trivial new method
        Sorted::insert(Updatable::instances, [instance, DEFAULT_PRIORITY])
        return instance
      end
    end
  end
end

#~ class Character
  #~ include Drawable
  #~ include Updatable
  
  #~ def draw
    #~ puts inspect
  #~ end
  
  #~ def update
    #~ puts inspect
  #~ end
  
  #~ def initialize(x,y)
    #~ @x = x
    #~ @y = y
    #~ yield if block_given?
  #~ end
#~ end

#~ class Enemy
  #~ include Drawable
  
  #~ def draw
    #~ puts inspect
  #~ end
  
  #~ def initialize
    #~ yield if block_given?
  #~ end
#~ end

#~ c1 = Character.new(0, 0){puts 'c1'}
#~ c2 = Character.new(1, 1){puts 'c2'}
#~ e1 = Enemy.new
#~ e2 = Enemy.new
#~ e3 = Enemy.new
#~ e4 = Enemy.new

#~ c1.draw_priority = 1
#~ e2.draw_priority = 2
#~ e3.draw_priority = 3
#~ c2.draw_priority = 4
#~ e4.draw_priority = 5

#~ c2.update_priority = -1

#~ puts '---update---'
#~ Updatable::do!
#~ puts '----draw----'
#~ Drawable::do!

#~ Drawable::remove(e2)
#~ Drawable::remove(e4)
#~ Updatable::remove(c2)

#~ puts '---update---'
#~ Updatable::do!
#~ puts '----draw----'
#~ Drawable::do!