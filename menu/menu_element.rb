module Ruby2D
  class MenuElement
    attr_reader :x, :y, :width, :height, :action

    def initialize opts = {}
      extend Ruby2D::DSL

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

      @hover_event = on :mouse_move do |e|
        if @background.contains? e.x, e.y
          @background.color = "black"
          @text.color = "white"
        else
          @background.color = "white"
          @text.color = "black"
        end
      end

      @mouse_up_event = on :mouse_up do |e|
        if @background.contains?(e.x, e.y) && @listener && @action
          @listener.instance_eval @action
        end
      end
    end

    def contains? x, y
      (@background.x..(@background.x + @background.width)).cover?(x) &&
        (@background.y..(@background.y + @background.height)).cover?(y)
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
