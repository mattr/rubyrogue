# Identity constants
  GAME_TITLE = "Ruby Roguelike"

# Time constants
  DAYS_PER_YEAR = 360
  HOURS_PER_DAY = 24
  MINUTES_PER_HOUR = 60
  SECONDS_PER_MINUTE = 60
  DAYS_PER_WEEK = 10
  # four seasons, ninety days a season, Spring begins on 45th day and ends on 134th day etc., Winter should wrap automatically
  SEASONS = {:Spring => 45...135, :Summer => 135...225, :Fall => 225...315, :Winter => 315...405}
  WEEKDAYS = [:Oneday, :Twoday, :Threeday, :Fourday, :Fiveday, :Sixday, :Sevenday, :Eightday, :Nineday, :Tenday]
  #placeholder month names, 12 months a year, 360/12 = 30 days a month, 3 weeks a month
  MONTHS = [:First, :Second, :Third, :Fourth, :Fifth, :Sixth, :Seventh, :Eighth, :Ninth, :Tenth, :Eleventh, :Twelfth]
 
# World map constants
MAP_HEIGHT = 0 # height value (0..1)
MAP_TEMP = 1 # contains mean temperature (biased by latitude and height) (0..1)
MAP_RAIN = 2 # contains mean rainfall (biased by rain shadow?) (0..100)
MAP_DRAIN = 3 # drainage (how much water is drained into soil) - fractal (0..100)
MAP_BIOME = 4 # biome, derived from height, temperature, rainfall and drainage parameters
MAP_FLORA = 5 # vegetation
MAP_FAUNA = 6 # wildlife
MAP_MISC = 8 # miscelaneous features

BIOMES = [ # elevation scalar [0,1], rainfall and drainage integer [0..100]
  # elevation < 0.25  
  :water,
  
  # elevation >= 0.25 and < 0.75
  # 0-9 rainfall
  :sand_desert, # 0-32 drainage
  :rock_desert,  # 33-49 drainage
  :badland_a, # 50-65 drainage
  :badland_b, # 66-100 drainage
  # 10-19 rainfall
 :grassland,#0-49 drainage
 :hills, #50-100 drainage
 # 20-32 rainfall
 :savanna, # 0-49 drainage
 :hills, #50-100 drainage
 # 33-65 rainfall
 :marsh, #0-32 drainage
 :shrubland, #33-49 drainage
 :hills, # 50-100 drainage
 #66-100 rainfall
 :swamp, # 0-32 drainage
 :forest, # 33-100 drainage
 # elevation >= 0.75 and < 0.83
 :low_mountain,
 # elevation >= 0.83 and < 0.9125
 :mountain,
 # elevation >= 0.9125 and < 0.9975
 :high_mountain,
 # elevation >= 0.9975
 :peak
  ]
  
# Input constants
  DELAY = 150 # milliseconds
  ALL_KEYS = {
    :'0' => [Gosu::Kb0, Gosu::KbNumpad0],
    :'1' => [Gosu::Kb1, Gosu::KbNumpad1],
    :'2' => [Gosu::Kb2, Gosu::KbNumpad2],
    :'3' => [Gosu::Kb3, Gosu::KbNumpad3],
    :'4' => [Gosu::Kb4, Gosu::KbNumpad4],
    :'5' => [Gosu::Kb5, Gosu::KbNumpad5],
    :'6' => [Gosu::Kb6, Gosu::KbNumpad5],
    :'7' => [Gosu::Kb7, Gosu::KbNumpad6],
    :'8' => [Gosu::Kb8, Gosu::KbNumpad7],
    :'9' => [Gosu::Kb9, Gosu::KbNumpad8],
    :A => [Gosu::KbA],
    :B => [Gosu::KbB],
    :C => [Gosu::KbC],
    :D => [Gosu::KbD],
    :E => [Gosu::KbE],
    :F => [Gosu::KbF],
    :G => [Gosu::KbG],
    :H => [Gosu::KbH],
    :I => [Gosu::KbI],
    :J => [Gosu::KbJ],
    :K => [Gosu::KbK],
    :L => [Gosu::KbL],
    :M => [Gosu::KbM],
    :N => [Gosu::KbN],
    :O => [Gosu::KbO],
    :P => [Gosu::KbP],
    :Q => [Gosu::KbQ],
    :R => [Gosu::KbR],
    :S => [Gosu::KbS],
    :T => [Gosu::KbT],
    :U => [Gosu::KbU],
    :V => [Gosu::KbV],
    :W => [Gosu::KbW],
    :X => [Gosu::KbX],
    :Y => [Gosu::KbY],
    :Z => [Gosu::KbZ],
    :backspace => [Gosu::KbBackspace],
    :delete => [Gosu::KbDelete],
    :down => [Gosu::KbDown],
    :end => [Gosu::KbEnd],
    :enter => [Gosu::KbEnter],
    :esc => [Gosu::KbEscape],
    :F1 => [Gosu::KbF1],
    :F10 => [Gosu::KbF10],
    :F11 => [Gosu::KbF11],
    :F12 => [Gosu::KbF12],
    :F2 => [Gosu::KbF2],
    :F3 => [Gosu::KbF3],
    :F4 => [Gosu::KbF4],
    :F5 => [Gosu::KbF5],
    :F6 => [Gosu::KbF6],
    :F7 => [Gosu::KbF7],
    :F8 => [Gosu::KbF8],
    :F9 => [Gosu::KbF9],
    :home => [Gosu::KbHome],
    :ins => [Gosu::KbInsert],
    :left => [Gosu::KbLeft],
    :'+' => [Gosu::KbNumpadAdd,13],
    :'/' => [Gosu::KbNumpadDivide],
    :'*' => [Gosu::KbNumpadMultiply],
    :'-' => [Gosu::KbNumpadSubtract],
    :pagedown => [Gosu::KbPageDown],
    :pageup => [Gosu::KbPageUp],
    :enter => [Gosu::KbReturn],
    :right => [Gosu::KbRight],
    :' ' => [Gosu::KbSpace],
    :tab => [Gosu::KbTab],
    :up => [Gosu::KbUp],
    :click_left => [Gosu::MsLeft],
    :click_middle => [Gosu::MsMiddle],
    :click_right => [Gosu::MsRight],
    :wheel_down => [Gosu::MsWheelDown],
    :wheel_up => [Gosu::MsWheelUp],
    :alt => [Gosu::KbRightAlt, Gosu::KbLeftAlt],
    :ctrl => [Gosu::KbRightControl, Gosu::KbLeftControl],
    :shift => [Gosu::KbRightShift, Gosu::KbLeftShift]
  }
  ALPHABET = ('A'..'Z').to_a.collect{|s| s.intern}
  NUMBERS = (0..9).to_a.collect{|n| n.to_s.intern}
  ALPHANUMERIC = ALPHABET+NUMBERS+[:' ']
  ARROWS = [:left,:right,:up,:down]
  PAGE_CONTROLS = [:home,:end,:pageup,:pagedown]
  FUNCTION_KEYS = [:F1,:F2,:F3,:F4,:F5,:F6,:F7,:F8,:F9,:F10,:F11,:F12]
  
# Display constants
  FRAME_DOUBLE=[:table_topleft_double, :table_topright_double, :table_bottomright_double, :table_bottomleft_double, :table_horizontal_double, :table_vertical_double]
  FRAME_SINGLE=[:table_topleft_single, :table_topright_single,  :table_bottomright_single, :table_bottomleft_single, :table_horizontal_single, :table_vertical_single]
  GRADIENT_GREYSCALE=Gradient.new(0xFF000000,0xFFFFFFFF)
  GRADIENT_COLOR_MAP=Gradient.new({
    0 => 0xFF000044,
    0.40 => 0xFF0000AA,
    0.405 => 0xFFFFFF00,
    0.41 => 0xFF00CC00,
    0.6 => 0xFF003300,
    0.74 => 0xFF663300,
    0.83 => 0xFFAAAAAA,
    0.93 => 0xFF444444,
    0.99 => 0xFFFFFFFF,
    1 => 0xFFFFFFFF
    })

# Tileset constants
  SYMBOLS = [
    :border, # 1px border around edges
    :face_empty, #transparent face
    :face_full, #full face
    :heart, #heart
    :diamond, #diamond
    :club, #cross leaf
    :spade, #fig leaf
    :circle, #full circle
    :box_hole, #block with hole
    :ring, #ring
    :box_ring_hole, #block with ring-shaped hole
    :male, #male symbol
    :female, #female symbol
    :tone_single, #single tone
    :tone_double, #double tone
    :sun, #sun symbol
    :triangle_right, #right triangle
    :triangle_left, #left triangle
    :arrows_updown,#up-down arrows
    :double_exclamation, # !!
    :pilcrow, # mirrored P
    :galaxy, # strange galaxy shaped thing
    :thick_line, # thick underscore
    :arrows_updown_line, # up-down arrows with undrscore
    :arrow_up, # up arrow
    :arrow_down, # down arrow
    :arrow_right, # right arrow
    :arrow_left, # left arrow
    :special_1, # |__
    :arrows_leftright, # left-right arrows
    :triangle_up, # up triangle
    :triangle_down, #down triangle

    :" ", #empty, space
    :"!", # !
    :'"', # "
    :"#", # #
    :"$", # $
    :"%", # %
    :"&", # &
    :"'", # '
    :"(", # (
    :")", # )
    :"*", # *
    :"+", # +
    :",", # ,
    :"-", # -
    :".", # .
    :"/", # /
    
    :"0", :"1", :"2", :"3", :"4", :"5", :"6", :"7", :"8", :"9", # 0123456789
    :":", # :
    :";", # ;
    :"<", # <s
    :"=", # =
    :">", # >
    :"?", # ?

    :"@", # @
    :A, :B, :C, :D, :E, :F, :G, :H, :I, :J, :K, :L, :M, :N, :O, :P, :Q, :R, :S, :T, :U, :V, :W, :X, :Y, :Z,
    :"[", # [
    :"\\", # \
    :"]", # ]
    :"^", # ^
    :"_", # _

    :"`", # `
    :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q, :r, :s, :t, :u, :v, :w, :x, :y, :z,
    :"{", # {
    :"|", # |
    :"}", # }
    :"~", # ~
    :house, # semi-triangle thing
# accents
    :C_cedilla,
    :u_umlaut,
    :e_acute,
    :a_circumflex,
    :a_umlaut,
    :a_grave,
    :a_ring,
    :c_cedilla,
    :e_circumflex,
    :e_umlaut,
    :e_grave,
    :i_umlaut,
    :i_circumflex,
    :i_grave,
    :A_umlaut,
    :A_ring,
# more accents
    :E_acute,
    :ae,
    :AE,
    :o_circumflex,
    :o_umlaut,
    :o_grave,
    :u_circumflex,
    :u_grave,
    :y_umlaut,
    :O_umlaut,
    :U_umlaut,
    :c_thing,
    :pound,
    :yen,
    :P_t, # Pt
    :function,
    :a_acute,
# damnit, more accents
    :i_acute,
    :o_acute,
    :u_acute,
    :n_tilde,
    :N_tilde,
    :a_line, # a on line
    :o_line, # o on line
    :reverse_question,
    :special_2, # negated negation?
    :negation, # negation symbol
    :half, # 1/2
    :quarter, # 1/4
    :reverse_exclamation, # reverse exclamation 
    :double_smaller, # <<
    :double_larger, # >>
    
    :fill25,
    :fill50,
    :fill75,
    :table_vertical_single,
    :table_forkleft_single,
    :table_forkleft_double_single,
    :table_forkleft_single_double,
    :table_topright_single_double,
    :table_topright_double_single,
    :table_forkleft_double,
    :table_vertical_double,
    :table_topright_double,
    :table_bottomright_double,
    :table_bottomright_single_double,
    :table_bottomright_double_single,
    :table_topright_single,
    
    :table_bottomleft_single,
    :table_forkup_single,
    :table_forkdown_single,
    :table_forkright_single,
    :table_horizontal_single,
    :table_cross_single,
    :table_forkright_single_double,
    :table_forkright_double_single,
    :table_bottomleft_double,
    :table_topleft_double,
    :table_forkup_double,
    :table_forkdown_double,
    :table_forkright_double,
    :table_horizontal_double,
    :table_cross_double,
    :table_forkup_double_single,

    :table_forkup_single_double,
    :table_forkdown_double_single,
    :table_forkdown_single_double,
    :table_bottomleft_single_double,
    :table_bottomleft_double_single,
    :table_topleft_double_single,
    :table_topleft_single_double,
    :table_cross_double_single,
    :table_cross_single_double,
    :table_bottomright_single,
    :table_topleft_single,
    :fill100,
    :fill_down,
    :fill_left,
    :fill_right,
    :fill_up,
    :alpha,
# woo, greek letters... note capitalization!
    :beta,
    :Gamma,
    :pi,
    :Sigma,
    :sigma,
    :mu,
    :tau,
    :Phi,
    :Theta,
    :Omega,
    :delta,
    :infinity,
    :phi,
    :epsilon,
    :union, # flipped U
    
    :equivalent, # three lines
    :plus_minus,
    :more_equal,
    :less_equal,
    :integral_top, # flipped J
    :integral_bottom, # J
    :division, # colon over minus
    :double_tilde,
    :degree, # ring
    :dot, # smallish dot
    :small_dot, # tiny dot 
    :root,
    :root_roof, # n
    :square, # 2
    :box, # square
    :fill # full fill without border
  ]
  ALTERNATE_SYMBOLS = {}