# Window constants
SCREEN_WIDTH=64 # in tiles
SCREEN_HEIGHT=48 #in tiles

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
HEIGHT = 0 #first value

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
  FUNCTION = [:F1,:F2,:F3,:F4,:F5,:F6,:F7,:F8,:F9,:F10,:F11,:F12]
  
# Display constants
  FRAME_DOUBLE=[:table_topleft_double, :table_topright_double, :table_bottomright_double, :table_bottomleft_double, :table_horizontal_double, :table_vertical_double]
  FRAME_SINGLE=[:table_topleft_single, :table_topright_single,  :table_bottomright_single, :table_bottomleft_single, :table_horizontal_single, :table_vertical_single]

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