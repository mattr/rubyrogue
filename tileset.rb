require 'gosu'

class Tileset < Gosu::Image
  SYMBOLS = [
    :null, #empty
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

    :space, #empty
    :exclamation, # !
    :quotes, # "
    :hash, # #
    :dollar, # $
    :percent, # %
    :ampersand, # &
    :quote, # '
    :open_parenthesis, # (
    :close_parenthesis, # )
    :star, # *
    :plus, # +
    :comma, # ,
    :minus, # -
    :period, # .
    :slash, # /
    
    :zero, :one, :two, :three, :four, :five, :six, :seven, :eight, :nine, # 0123456789
    :colon, # :
    :semicolon, # ;
    :less, # <
    :equal, # =
    :more, # >
    :question, # ?

    :at, # @
    :A, :B, :C, :D, :E, :F, :G, :H, :I, :J, :K, :L, :M, :N, :O, :P, :Q, :R, :S, :T, :U, :V, :W, :X, :Y, :Z,
    :open_bracket, # [
    :backslash, # \
    :close_bracket, # ]
    :caret, # ^
    :underscore, # _

    :backquote, # `
    :a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :q, :r, :s, :t, :u, :v, :w, :x, :y, :z,
    :open_curly, # {
    :pipe, # |
    :close_curly, # }
    :tilde, # ~
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
    :empty # nothing
  ]

 
ALTERNATE_SYMBOLS = {}

  def Tileset.new(window, filename="Cooz_16x16.png", symbols = SYMBOLS, alternate = ALTERNATE_SYMBOLS) # filenames are case sensitive on some OSes
    tileset_array = Tileset.load_tiles(window, filename, 16, 16, 0)
    hash = Hash[*symbols.zip(tileset_array).flatten]
    alternate.each {|key, value| hash[key] = hash[value]}
    return hash
  end
end