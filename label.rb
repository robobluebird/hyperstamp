module Ruby2D
  class Label
    attr_reader :x, :y, :z, :width, :height

    def initialize opts = {}
      extend Ruby2D::DSL

      @rendered = false
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 0
      @height = opts[:height] || 0
      @text = opts[:text] || 'label'

      @font = Font.new(
        type: (opts.dig(:font, :type) || :lux).to_sym,
        size: opts.dig(:font, :size) || 12
      )

      @hover_event = on :mouse_move do |e|
        if @rendered
          if @content.contains? e.x, e.y
            @content.color = "black"
            @text.color = "white"
          else
            @content.color = "white"
            @text.color = "black"
          end
        end
      end
    end

    def remove
      @highlight.remove
      @content.remove
      @text.remove
    end

    def add
      if @rendered
        @highlight.add
        @content.add
        @text.add
      else
        render!
      end
    end

    def resize dx, dy
      @width = @width + dx
      @height = @height + dy

      @highlight.resize dx, dy

      @content.width = @content.width + dx
      @content.height = @content.height + dy

      arrange_text!
    end

    def x= x
      @x = x
      @highlight.move_to @x, @y
      @content.x = @x
      arrange_text!
    end

    def y= y
      @y = y
      @highlight.move_to @x, @y
      @content.y = @y
      arrange_text!
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @content.x = @content.x + dx
      @content.y = @content.y + dy

      @highlight.translate dx, dy

      @text.x = @text.x + dx
      @text.y = @text.y + dy
    end

    def highlight
      @highlight.show
    end

    def unhighlight
      @highlight.hide
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    private

    def render!
      @highlight = Border.new(
        z: @z,
        x: @x - 5,
        y: @y - 5,
        width: @width + 10,
        height: @height + 10,
        thickness: 5,
        color: 'blue'
      )

      @highlight.hide

      @content = Rectangle.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height
      )

      @text = Text.new(
        z: @z,
        x: @x,
        text: @text,
        font: @font.file,
        size: @font.size.to_i,
        color: 'black'
      )

      @width = @text.width if @width.zero?
      @height = @text.height if @height.zero?

      @highlight.resize_to @width + 10, @height + 10
      @content.width = @width
      @content.height = @height

      arrange_text!

      @rendered = true
    end

    def arrange_text!
      @text.y = @y + (@height / 2) - @text.height / 2
    end
  end
end
