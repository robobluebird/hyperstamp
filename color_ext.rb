module Ruby2D
  class Color
    def to_hex
      r = (@r * 255).to_i.to_s(16).rjust(2, '0')
      g = (@g * 255).to_i.to_s(16).rjust(2, '0')
      b = (@b * 255).to_i.to_s(16).rjust(2, '0')

      "##{r}#{g}#{b}"
    end
  end
end
