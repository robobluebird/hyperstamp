module Ruby2D
  class Button < Rectangle
    attr_accessor :tag, :label, :on_click
    attr_reader :color_scheme, :style

    def initialize opts = {}
      @on_click = opts[:on_click] || opts['on_click']
      @tag = opts[:tag] || opts['tag']
      @label = opts[:label] || opts['label'] || 'button'

      opts[:color] = 'white'

      z      = opts[:z] || opts['z']
      x      = opts[:x] || opts['x']
      y      = opts[:y] || opts['y']
      width  = opts[:width] || opts['width']
      height = opts[:height] || opts['height']

      @focus = Rectangle.new(
        z: z,
        x: x - 5,
        y: y - 5,
        width: width + 10,
        height: height + 10,
        color: 'blue'
      )

      @focus.opacity = 0

      @border = Rectangle.new(
        z: z,
        x: x - 1,
        y: y - 1,
        width: width + 2,
        height: height + 2,
        color: 'black'
      )

      @shadow = Rectangle.new(
        z: z,
        x: x + 2,
        y: y + 2,
        width: width,
        height: height,
        color: 'black'
      )

      super opts

      @font = Font.new(
        type: (opts.dig(:font, :type) || :lux).to_sym,
        size: opts.dig(:font, :size)
      )

      @text = Text.new(
        z: z,
        text: @label,
        font: @font.file,
        size: @font.size.to_i,
        color: 'black'
      )

      self.style = (opts[:style] || opts['style'] || :opaque).to_sym
      self.color_scheme = (opts[:color_scheme] || opts['color_scheme'] || :black_on_white).to_sym

      arrange_text!
    end

    def to_h
      {
        type: 'button',
        label: @label,
        tag: @tag,
        x: self.x,
        y: self.y,
        height: self.height,
        width: self.width,
        style: @style,
        color_scheme: @color_scheme,
        on_click: @on_click,
        font: {
          type: @font.type,
          size: @font.size.to_s
        }
      }
    end

    def color_scheme= scheme
      case scheme
      when :black_on_white
        @border.color = 'black'
        @shadow.color = 'black'
        @text.color = 'black'
        self.color = 'white'
      when :white_on_black
        @border.color = 'white'
        @border.color = 'white'
        @text.color = 'white'
        self.color = 'black'
      else
        raise
      end

      @color_scheme = scheme

      self.style = @style
    end

    def style= style
      case style
      when :opaque
        @border.opacity = 1
        @shadow.opacity = 1
        self.opacity = 1
      when :transparent
        @border.opacity = 0
        @shadow.opacity = 0
        self.opacity = 0
      else
        raise
      end

      @style = style
    end

    def z= new_z
      @focus.z = new_z
      @border.z = new_z
      @shadow.z = new_z
      super new_z
      @text.z = new_z
    end

    def translate dx, dy
      self.x = @x + dx
      self.y = @y + dy

      @focus.x = @focus.x + dx
      @focus.y = @focus.y + dy

      @text.x = @text.x + dx
      @text.y = @text.y + dy

      @border.x = @border.x + dx
      @border.y = @border.y + dy

      @shadow.x = @shadow.x + dx
      @shadow.y = @shadow.y + dy
    end

    def resize dx, dy
      self.width = @width + dx
      self.height = @height + dy

      resize!
      arrange_text!
    end

    def destroy
      @text.remove
      @border.remove
      @shadow.remove
      self.remove
    end

    def invert
      self.color = 'black'
      @text.color = 'white'
      @border.color = 'white'
      @shadow.color = 'white'
    end

    def revert
      self.color = 'white'
      @text.color = 'black'
      @border.color = 'black'
      @shadow.color = 'black'
      self.style = @style
      self.color_scheme = @color_scheme
    end

    def focus
      @focus.opacity = 1
    end

    def defocus
      @focus.opacity = 0
    end

    def editable?
      false
    end

    private

    def arrange_text!
      @text.x = self.x + (self.width / 2) - @text.width / 2
      @text.y = self.y + (self.height / 2) - @text.height / 2
    end

    def resize!
      @focus.width = self.width + 10
      @focus.height = self.height + 10
      @border.width = self.width + 2
      @border.height = self.height + 2
      @shadow.width = self.width
      @shadow.height = self.height
    end
  end
end
