module Ruby2D
  class List
    attr_reader :x, :y, :width, :height, :z, :items

    def initialize opts = {}
      @rendered = false
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 100
      @height = opts[:height] || 100
      @items = opts[:items] || []
      @rendered_items = []
    end

    def remove
    end

    def add
      if @rendered
      else
        render!
      end
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    private

    def render!
      @rendered = true

      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height
      )

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2)
      )

      layout_items!
    end

    def layout_items!
      y = @y

      @items.each do |item|
        item_element = Label.new(
          text: item[:text],
          z: @z,
          x: @x,
          y: y,
          width: @content.width,
          height: 20
        )

        y += 20

        @rendered_items << item_element
      end
    end
  end
end
