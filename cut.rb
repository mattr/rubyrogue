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
end