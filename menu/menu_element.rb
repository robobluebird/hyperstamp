module Ruby2D
  class MenuElement
    attr_reader :x, :y, :width, :height

    def initialize opts = {}
      @x = opts[:x]
      @y = opts[:y]
      @height = 20
      @z = 2000

      @border = Border.new(
        x: @x,
        y: @y,
        width: 0,
        height: @height,
        z: z
      )

      @background = Rectangle.new(
        x: @x + 1,
        y: @y + 1,
        width: 0,
        height: @height - 2,
        color: 'white',
        z: z
      )

      @text = Text.new(
        x: @x + 1,
        y: @y + 1,
        height: @height,
        text: opts[:text],
        color: 'black',
        font: 'fonts/lux.ttf',
        size: 12,
        z: z
      )

      @width = @text.width + 20 + 2 # for border
      @height = @text.height + 2

      @border.width = @width
      @border.height = @height

      @background.width = @width - 2
      @background.height = @height - 2

      @text.x = @text.x + 10
    end

    def remove
      @border.remove
      @background.remove
      @text.remove
    end

    def add
      @border.add
      @background.add
      @text.add
    end

    def width= width
      @width = width
      @border.width = width
      @background.width = width - 2
    end
  end
end
