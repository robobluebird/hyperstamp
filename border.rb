require 'Ruby2D'

module Ruby2D
  class Border
    attr_reader :x, :y, :width, :height, :thickness

    def initialize opts = {}
      @z = opts[:z]
      @x = opts[:x]
      @y = opts[:y]
      @width = opts[:width]
      @height = opts[:height]
      @thickness = opts[:thickness] || 1
      @factor = @thickness.to_f / 2
      @color = opts[:color] || 'black'

      @top = Line.new(
        z: @z,
        width: @thickness,
        x1: opts[:x],
        y1: opts[:y] + @factor,
        x2: opts[:x] + opts[:width],
        y2: opts[:y] + @factor,
        color: @color)

      @right = Line.new(
        z: @z,
        width: @thickness,
        x1: opts[:x] + opts[:width] - @factor,
        y1: opts[:y],
        x2: opts[:x] + opts[:width] - @factor,
        y2: opts[:y] + opts[:height],
        color: @color)

      @bottom = Line.new(
        z: @z,
        width: @thickness,
        x1: opts[:x],
        y1: opts[:y] + opts[:height] - @factor,
        x2: opts[:x] + opts[:width],
        y2: opts[:y] + opts[:height] - @factor,
        color: @color)

      @left = Line.new(
        z: @z,
        width: @thickness,
        x1: opts[:x] + @factor,
        y1: opts[:y],
        x2: opts[:x] + @factor,
        y2: opts[:y] + opts[:height],
        color: @color)

      @only = Array(opts[:only] || []).map(&:to_sym)

      show
    end

    def color= color
      @color = color
      @top.color = color
      @right.color = color
      @bottom.color = color
      @left.color = color
    end

    def z
      @z
    end

    def z= new_z
      @top.z = new_z
      @right.z = new_z
      @bottom.z = new_z
      @left.z = new_z
    end

    def remove
      @top.remove
      @right.remove
      @bottom.remove
      @left.remove
    end

    def add
      @top.add
      @right.add
      @bottom.add
      @left.add
    end

    def show
      all = @only.empty?
      @top.opacity = all || @only.include?(:top) ? 1 : 0
      @right.opacity = all || @only.include?(:right) ? 1 : 0
      @bottom.opacity = all || @only.include?(:bottom) ? 1 : 0
      @left.opacity = all || @only.include?(:left) ? 1 : 0
    end

    def hide
      @top.opacity = 0
      @right.opacity = 0
      @bottom.opacity = 0
      @left.opacity = 0
    end

    def resize dx, dy
      @width += dx
      @height += dy
      size_up!
    end

    def width= width
      @width = width
      size_up!
    end

    def height= height
      @height = height
      size_up!
    end

    def translate dx, dy
      @x += dx
      @y += dy
      size_up!
    end

    def contains? x, y
      (@x..(@x + @width)).cover?(x) && (@y..(@y + @height)).cover?(y)
    end

    private

    def size_up!
      @top.x1 = @x
      @top.y1 = @y + @factor
      @top.x2 = @x + @width
      @top.y2 = @y + @factor

      @right.x1 = @x + @width - @factor
      @right.y1 = @y
      @right.x2 = @x + @width - @factor
      @right.y2 = @y + @height

      @bottom.x1 = @x
      @bottom.y1 = @y + @height - @factor
      @bottom.x2 = @x + @width
      @bottom.y2 = @y + @height - @factor

      @left.x1 = @x + @factor
      @left.y1 = @y
      @left.x2 = @x + @factor
      @left.y2 = @y + @height
    end
  end
end
