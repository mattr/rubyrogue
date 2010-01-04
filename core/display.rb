# Low level functions

class Tileset < Gosu::Image

  def Tileset.new(window, filename="./images/"+FILE_TILESET, symbols = SYMBOLS, alternate = ALTERNATE_SYMBOLS) # filenames are case sensitive on some OSes
    tileset_array = Tileset.load_tiles(window, filename, 16, 16, 0)
    hash = Hash[*symbols.zip(tileset_array).flatten]
    alternate.each{|key, value| hash[key] = hash[value]}
    return hash
  end
end

module Display
  def self.blit(x, y, z, symbol=:fill100,color=0xFFFFFFFF) #faster than draw_rot
    if (x >= 0 and x < SCREEN_TILE_WIDTH) and #don't draw out of bounds
      (y >= 0 and y < SCREEN_TILE_HEIGHT) then
      $game.tileset[symbol].draw(x*TILE_SIZE[0], y*TILE_SIZE[1], z, 1, 1, color)
    end
  end
  
  def self.blit_rot(x, y, z, symbol=:fill100,color=0xFFFFFFFF,angle=0,scale=[1,1]) #slower than draw_tile
    if (x >= 0 and x < SCREEN_TILE_WIDTH) and #don't draw out of bounds
      (y >= 0 and y < SCREEN_TILE_HEIGHT) then
      $game.tileset[symbol].draw_rot(x*TILE_SIZE[0]+TILE_SIZE[0]*0.5, y*TILE_SIZE[1]+TILE_SIZE[1]*0.5, z, angle, 0.5, 0.5, scale[0],scale[1], color)
    end
  end
  
  def self.blit_scale(x, y, width=1, height=1, z=0, color=0xFFFFFFFF, style=:fill)
      $game.tileset[style].draw(x*TILE_SIZE[0],y*TILE_SIZE[1], z, width, height, color)
    end

  def self.blit_map(x, y, width, height, source, offset_x=0, offset_y=0, tilable_x=false, tilable_y=false, zoom=1)
    # x, y : screen coords, width, height: rectangle size, source: map/array, offset: coords within source, tilable: wrapping or not
    map_width = source[0].length
    map_height = source.length
    height.times do |j|
      width.times do |i|
          screen_x = x + i
          screen_y = y + j
          if tilable_x and tilable_y then #wrap both ways
            map_x = (offset_x + i*zoom) % map_width
            map_y = (offset_y + j*zoom) % map_height
            Display.blit(screen_x,screen_y,0,source[map_y][map_x][0],source[map_y][map_x][1])
          elsif tilable_x and not tilable_y then #wrap horizontally only
            map_y = offset_y + j*zoom
            if map_y>=0 and map_y<map_height then
              map_x = (offset_x + i*zoom) % map_width
              Display.blit(screen_x,screen_y,0,source[map_y][map_x][0],source[map_y][map_x][1])
            end
          elsif not tilable_x and tilable_y then # wrap vertically only
            map_x = offset_x + i*zoom
            if map_x>=0 and map_x < map_width then
              map_y = (offset_y + j*zoom) % map_height
              Display.blit(screen_x,screen_y,0,source[map_y][map_x][0],source[map_y][map_x][1])              #nope
            end
          else #no wrapping at all
            map_x = offset_x + i*zoom
            map_y = offset_y + j*zoom
            if (map_x >= 0 and map_x < map_width) and (map_y >=0 and map_y < map_height) then
              Display.blit(screen_x,screen_y,0,source[map_y][map_x][0],source[map_y][map_x][1])
            end
          end
        end
    end
  end
end