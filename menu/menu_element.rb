module Ruby2D
  class MenuElement
    attr_reader :x, :y, :z, :width, :height, :action

    def initialize opts = {}
      @selected = false
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

      @words = opts[:text]

      @text = Text.new(
        opts[:text],
        x: @x + 1,
        y: @y + 1,
        height: @height,
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

    def text
      @words
    end

    def selected?
      @selected
    end

    def select
      invert
      @selected = true
      self
    end

    def deselect
      revert
      @selected = false
      self
    end

    def invert
      @background.color = 'black'
      @text.color = 'white'
    end

    def revert
      @background.color = 'white'
      @text.color = 'black'
    end

    def hover_on x, y
      @background.color = "black"
      @text.color = "white"
    end

    def hover_off x, y
      return if selected?

      @background.color = "white"
      @text.color = "black"
    end

    def mouse_up x, y, button
      if @listener && @action
        @listener.instance_eval @action
      end
    end

    def mouse_down x, y, button
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

      if @selected
        invert
      else
        revert
      end

      self
    end

    def width= width
      @width = width
      @border.width = width
      @background.width = width - 2
    end
  end
end
