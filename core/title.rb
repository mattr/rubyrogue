# Title screen

class TitleScreen
  include Updatable
  include Drawable
  include Inputable
  attr_accessor :keys
  
  KEYS = [:up, :down, :enter]
  
  def initialize
    @keys=[]
    @border_frame=create(@border_frame,Frame,0,0,SCREEN_TILE_WIDTH,SCREEN_TILE_HEIGHT,0,0xFFAAAAAA,:single)
    @title_frame=create(@title_frame,Frame,24,0,16,3,0,0xFFAAAAAA,:single)
    @title_text=create(@title_text,Text,25,1,'Ruby Roguelike',0xFFFF0000)
    @option_1=create(@option_1,Text,24,23,'Create new world',0xFFAAAAAA)
    @option_2=create(@option_2,Text,21,25,'Just some random text',0xFFAAAAAA)
    @option_3=create(@option_3,Text,30,27,'Exit',0xFFAAAAAA)
    @selected=@option_1
    @selected.color=0xFFFFFFFF
  end
  
  def update
    if Keys.ready?(self, :down) then
      if @selected==@option_1 then
        @selected=@option_2
        @option_1.color=0xFFAAAAAA
        @option_2.color=0xFFFFFFFF
      elsif @selected==@option_2 then
        @selected=@option_3
        @option_2.color=0xFFAAAAAA
        @option_3.color=0xFFFFFFFF
      else
      end
    elsif Keys.ready?(self, :up) then
      if @selected==@option_2 then
        @selected=@option_1
        @option_2.color=0xFFAAAAAA
        @option_1.color=0xFFFFFFFF
      elsif @selected==@option_3 then
        @selected=@option_2
        @option_3.color=0xFFAAAAAA
        @option_2.color=0xFFFFFFFF
      else
      end
    end
    
    if Keys.triggered?(self,:enter) then
      if @selected==@option_1 then
        #create world
        $game.state=:create_world
        self.remove
      elsif @selected==@option_3 then
        $game.close
      else
        #nothing
      end
    end
  end
  
  def draw
    
  end
  
  def remove
    Updatable::remove(self)
    Drawable::remove(self)
    Inputable::remove(self)
    @selected=nil
    Handler.destroy(@border_frame,@title_text, @title_frame, @option_1, @option_2, @option_3)
  end
end