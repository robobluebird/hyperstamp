require 'ruby2d'

# m = MiniMagick::Image.new('tape2.jpg')
# m.format 'png'
# m.resize '512x512'
# m.ordered_dither 'o3x3'
# m.depth 4
# m.colorspace 'Gray'
# m.scale '10%'
# m.scale '1000%'
# m.write 'images/tape2.png'

module Ruby2D
  class MyImage < Image
    def initialize opts = {}
      super opts

      @rd = self.width >= self.height ? :horizontal : :vertical
      @r = @rd == :horizontal ? self.height.to_f / self.width : self.width.to_f / self.height
    end

    def translate dx, dy
      self.x = @x + dx
      self.y = @y + dy
    end

    def resize dx, dy
      if !dx.to_i.zero?
        self.width = @width + dx

        if @rd == :horizontal
          self.height = self.width * @r
        else
          self.height = self.width / @r
        end
      else
        self.height = @height + dy

        if @rd == :horizontal
          self.width = self.height / @r
        else
          self.width = self.height * @r
        end
      end
    end
  end
end
