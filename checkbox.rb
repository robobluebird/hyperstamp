module Ruby2D
  class Checkbox
    attr_reader :z, :x, :y, :width, :height, :checked
    attr_accessor :tag

    def initialize opts = {}
      @visible = false
      @listener = opts[:listener]
      @action = opts[:action]
      @z = opts[:z]
      @x = opts[:x]
      @y = opts[:y]
      @tag = opts[:tag]
      @width = 20
      @height = 20
      @checked = false
    end

    def checked?
      @checked
    end

    def checked= check
      [true, false].include?(check) ? @checked = check : raise('bad value for checkbox')
    end

    def visible?
      @visible
    end

    def add
      if @rendered
        @border.add
        @content.add
      else
        render!
      end

      @visible = true

      self
    end

    def remove
      @border.remove
      @content.remove

      @visible = false

      self
    end

    def uncheck
      @content.color = 'white'
      @checked = false
    end

    def check
      @content.color = 'black'
      @checked = true
    end

    def hover_on x, y; end

    def hover_off x, y; end

    def mouse_down x, y, button
    end

    def mouse_up x, y, button
      if @checked
        uncheck
      else
        check
      end
    end

    def contains? x, y
      (@x..(@x + @width)).cover?(x) &&
        (@y..(@y + @height)).cover?(y)
    end

    private

    def render!
      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height,
        thickness: 2
      )

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2)
      )

      @rendered = true
    end
  end
end
