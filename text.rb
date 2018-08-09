require 'ruby2d'

module Ruby2D
  class TextBox
    def initialize opts = {}
      @show_border = true

      @border = Rectangle.new(
        z: opts[:z],
        x: opts[:x] - 1,
        y: opts[:y] - 1,
        width: opts[:width] + 2,
        height: opts[:height] + 2,
        color: 'black')

      @text = Text.new(
        z: opts[:z],
        text: @label,
        font: 'luximb.ttf',
        size: 12,
        color: 'black')
    end
  end
end
