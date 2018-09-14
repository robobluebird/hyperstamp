module Ruby2D
  class MenuElement
    attr_reader :x, :y, :z, :width, :height, :action

    def initialize opts = {}
      @visible = false
      @listener = opts[:listener]
      @x = opts[:x]
      @y = opts[:y]
      @height = 20
      @z = 2000
      @action = opts[:action]

      @border = Border.new(
        x: @x,
        y: @y,
        width: 0,
        height: @height,
        z: @z
      )

      @background = Rectangle.new(
        x: @x + 1,
        y: @y + 1,
        width: 0,
        height: @height - 2,
        color: 'white',
        z: @z
      )

      @text = Text.new(
        x: @x + 1,
        y: @y + 1,
        height: @height,
        text: opts[:text],
        color: 'black',
        font: 'fonts/lux.ttf',
        size: 12,
        z: @z
      )

      @width = @text.width + 20 + 2 # for border
      @height = @text.height + 2

      @border.width = @width
      @border.height = @height

      @background.width = @width - 2
      @background.height = @height - 2

      @text.x = @text.x + 10
    end

    def hover_on x, y
      @background.color = "black"
      @text.color = "white"
    end

    def hover_off x, y
      @background.color = "white"
      @text.color = "black"
    end

    def mouse_up x, y
      if @listener && @action
        @listener.instance_eval @action
      end
    end

    def contains? x, y
      (@background.x..(@background.x + @background.width)).cover?(x) &&
        (@background.y..(@background.y + @background.height)).cover?(y)
    end

    def visible?
      @visible
    end

    def remove
      @border.remove
      @background.remove
      @text.remove

      @visible = false

      self
    end

    def add
      @border.add
      @background.add
      @text.add

      @visible = true

      self
    end

    def width= width
      @width = width
      @border.width = width
      @background.width = width - 2
    end
  end
end
