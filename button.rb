require 'ruby2d'

module Ruby2D
  class Button < Rectangle
    attr_accessor :tag, :label, :on_click

    def initialize opts = {}
      @on_click = opts[:on_click]
      @show_border = true
      @tag = opts[:tag]
      @label = opts[:label] || 'button'

      opts[:color] = 'white'

      @focus = Rectangle.new(
        z: opts[:z],
        x: opts[:x] - 5,
        y: opts[:y] - 5,
        width: opts[:width] + 10,
        height: opts[:height] + 10,
        color: 'blue')

      @focus.opacity = 0

      @border = Rectangle.new(
        z: opts[:z],
        x: opts[:x] - 1,
        y: opts[:y] - 1,
        width: opts[:width] + 2,
        height: opts[:height] + 2,
        color: 'black')

      @shadow = Rectangle.new(
        z: opts[:z],
        x: opts[:x] + 2,
        y: opts[:y] + 2,
        width: opts[:width],
        height: opts[:height],
        color: 'black')

      super opts

      @text = Text.new(
        z: opts[:z],
        text: @label,
        font: 'luximb.ttf',
        size: 12,
        color: 'black')

      arrange_text!
    end

    def border?
      @show_border
    end

    def show_border
      @border.opacity = 1
      @shadow.opacity = 1
      self.opacity = 1
      @show_border = true
    end

    def hide_border
      @border.opacity = 0
      @shadow.opacity = 0
      self.opacity = 0
      @show_border = false
    end

    def z= new_z
      @focus.z = new_z
      @shadow.z = new_z
      @border.z = new_z
      super new_z
      @text.z = new_z

      puts "focus z = #{@focus.z}"
      puts "shadow z = #{@shadow.z}"
      puts "border z = #{@border.z}"
      puts "self z = #{self.z}"
      puts "text z = #{@text.z}"
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

    def remove
      @text.remove
      @border.remove
      @shadow.remove

      super
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
      hide_border unless @show_border
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
