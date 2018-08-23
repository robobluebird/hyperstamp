module Ruby2D
  class Button
    attr_accessor :tag, :label, :on_click
    attr_reader :color_scheme, :style, :x, :y, :width, :height, :z

    def initialize opts = {}
      @rendered = false
      @on_click = opts[:on_click]
      @tag = opts[:tag]
      @label = opts[:label] || 'button'
      @style = (opts[:style] || :opaque).to_sym
      @color_scheme = (opts[:color_scheme] || :black_on_white).to_sym

      @z      = opts[:z] || 0
      @x      = opts[:x] || 0
      @y      = opts[:y] || 0
      @width  = opts[:width] || 100
      @height = opts[:height] || 50

      @font = Font.new(
        type: (opts.dig(:font, :type) || :lux).to_sym,
        size: opts.dig(:font, :size)
      )
    end

    def remove
      @highlight.remove
      @text.remove
      @border.remove
      @shadow.remove
      @content.remove
    end

    def add
      if @rendered
        @highlight.add
        @border.add
        @shadow.add
        @content.add
        @text.add
      else
        render!
      end
    end

    def to_h
      {
        type: 'button',
        label: @label,
        tag: @tag,
        x: @x,
        y: @y,
        height: @height,
        width: @width,
        style: @style,
        color_scheme: @color_scheme,
        on_click: @on_click,
        font: {
          type: @font.type,
          size: @font.size.to_s
        }
      }
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    def color_scheme= scheme
      case scheme
      when :black_on_white
        @border.color = 'black'
        @shadow.color = 'black'
        @text.color = 'black'
        @content.color = 'white'
      when :white_on_black
        @border.color = 'white'
        @border.color = 'white'
        @text.color = 'white'
        @content.color = 'black'
      else
        raise
      end

      @color_scheme = scheme

      self.style = @style
    end

    def style= style
      case style
      when :opaque
        @border.show
        @shadow.show
        @content.opacity = 1
      when :transparent
        @border.hide
        @shadow.hide
        @content.opacity = 0
      else
        raise
      end

      @style = style
    end

    def z= new_z
      @highlight.z = new_z
      @border.z = new_z
      @shadow.z = new_z
      @content.z = new_z
      @text.z = new_z
    end

    def resize dx, dy
      @width = @width + dx
      @height = @height + dy

      @highlight.resize dx, dy
      @border.resize dx, dy
      @shadow.resize dx, dy

      @content.width = @content.width + dx
      @content.height = @content.height + dy

      arrange_text!
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @highlight.translate dx, dy
      @border.translate dx, dy
      @shadow.translate dx, dy

      @content.x = @content.x + dx
      @content.y = @content.y + dy

      @text.x = @text.x + dx
      @text.y = @text.y + dy
    end

    def invert
      @content.color = 'black'
      @text.color = 'white'
      @border.color = 'white'
      @shadow.color = 'white'
    end

    def revert
      @content.color = 'white'
      @text.color = 'black'
      @border.color = 'black'
      @shadow.color = 'black'
      self.style = @style
      self.color_scheme = @color_scheme
    end

    def highlight
      @highlight.show
    end

    def unhighlight
      @highlight.hide
    end

    def editable?
      false
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

      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height,
        thickness: 1,
        color: 'black'
      )

      @shadow = Border.new(
        z: @z,
        x: @x + 2,
        y: @y + 2,
        width: @width,
        height: @height,
        thickness: 2,
        color: 'black'
      )

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2),
        color: 'white'
      )

      @text = Text.new(
        z: @z,
        text: @label,
        font: @font.file,
        size: @font.size.to_i,
        color: 'black'
      )

      style = @style
      color_scheme = @color_scheme

      arrange_text!

      @rendered = true
    end

    def arrange_text!
      @text.x = @x + (@width / 2) - @text.width / 2
      @text.y = @y + (@height / 2) - @text.height / 2
    end
  end
end
