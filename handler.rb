# handle, uh, stuff like Updatable, Drawable and such
module Handler

#sample syntax: @var=create(@var,Text,x,y,"Actual text",color)
  def create(*args, &block)
	if args[0] then args[0].remove end
	return args[1].new(*args[2..-1], &block)
  end

  def self.clear #this clears all drawable and updatable instances from the handlers
	Drawable.instances.clear
	Updatable.instances.clear
  end

  def self.remove(*args) #remove selected instances
	args.each {|item| if item then item.remove end}
  end
end
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
    @instances.delete([obj, obj.draw_priority]) # this is also suboptimal (O(n) rather than log(n))
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
    @instances.delete([obj, obj.update_priority]) # this is also suboptimal (O(n) rather than log(n))
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

# passes input to input handlers, effectively filtering it
module Inputable
	class << self; attr_accessor :handlers, :input end
	@handlers=[]
	@input=[]
	
	def self.do!
		@handlers.each do |handler|
		handle(handler)
		break if @input.empty?
		end
	end
	
	def self.included(base)
		class << base
			alias :inputable_old_new new
			def new(*args,&block)
				instance=inputable_old_new(*args,&block)
				Inputable::handlers.unshift(instance) #this puts the instance in front of the queue
				return instance
			end
		end
	end
	
	def self.handle(instance) #handle the keyboard input
		instance.keys.clear #reset the instance's list of keys first
		instance.class::KEYS.each do |key|
			if @input.include?(key) then
					instance.keys << key
					@input.delete(key)
			end
		end
	end
	
	def self.remove(obj)
		@handlers.delete(obj)
	end
end