# Fractal Noise

module FractalNoise
  def self.octave(octave, base, noise, persistence, offset=[0, 0], tilable=[true, true])
    return nil if persistence == 0
    
    base_height, base_width = base.length.to_f, base[0].length.to_f
    noise_height, noise_width = noise.length.to_f, noise[0].length.to_f
    
    # We want to slice base into pieces that are roughly square in shape.
    # Each of those squares will correspond to one cell in the noise array
    if base_height > base_width then # make 2**octave vertical cuts, then some greater number of horizontal cuts
      cuts_x = 2**octave
      slice_width = base_width/cuts_x
      cuts_y = (base_height/slice_width).ceil
      slice_height = base_height/cuts_y
    else # make 2**octave HORIZONTAL cuts, then some greater number of VERTICAL cuts
      cuts_y = 2**octave
      slice_height = base_height/cuts_y
      cuts_x = (base_width/slice_height).ceil
      slice_width = base_width/cuts_x
    end
    
    # Wrap around: either after as many steps as there are cuts, or after as many steps as possible.
    # That is, if tiling is necessary.
    wrap_x = tilable[0] ? [cuts_x, noise_width].min : noise_width
    wrap_y = tilable[1] ? [cuts_y, noise_height].min : noise_height
    
    base.length.times do |j|
      cy = offset[1]+j.to_f/slice_height # j/slice_height = what is the number of the slice j falls into
      coef_y = cy-cy.floor
      y0 = (cy.floor-1) % wrap_y
      y1 = cy.floor % wrap_y
      base[0].length.times do |i|
        cx = offset[0]+i.to_f/slice_width
        coef_x = cx-cx.floor
        x0 = (cx.floor-1) % wrap_x
        x1 = cx.floor % wrap_x
        top = lerp(noise[y0][x0], noise[y0][x1], coef_x)
        bottom = lerp(noise[y1][x0], noise[y1][x1], coef_x)
        base[j][i] += lerp(top, bottom, coef_y)*persistence
      end
    end
  end
end
