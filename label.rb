module Ruby2D
  class Label
    attr_reader :x, :y, :z, :width, :height, :words
    attr_accessor :tag

    def initialize opts = {}
      extend Ruby2D::DSL

      @visible = false
      @first_click = nil
      @rendered = false

      @listener = opts[:listener]
      @action = opts[:action]
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 0
      @height = opts[:height] || 0
      @words = opts[:text] || 'label'
      @tag = opts[:tag]

      @font = Font.new(
        type: (opts.dig(:font, :type) || :lux).to_sym,
        size: opts.dig(:font, :size) || 12
      )
    end

    def visible?
      @visible
    end

    def remove
      @highlight.remove
      @content.remove
      @text.remove

      @visible = false

      self
    end

    def add
      if @rendered
        @highlight.add
        @content.add
        @text.add
      else
        render!
      end

      @visible = true

      self
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

    def invert
      @content.color = "black"
      @text.color = "white"
    end

    def revert
      @content.color = "white"
      @text.color = "black"
    end

    def hover_on x, y
      invert
    end

    def hover_off x, y
      revert
    end

    def mouse_up x, y, button
      if @first_click && Time.now.to_f - @first_click < 0.20
        if @listener && @action
          @listener.instance_eval @action
        end

        @first_click = nil
      elsif @content.contains? e.x, e.y
        @first_click = Time.now.to_f
      end
    end

    def mouse_down x, y, button
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
        text: @words,
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
