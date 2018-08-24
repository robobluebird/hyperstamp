module Ruby2D
  class List
    attr_reader :x, :y, :width, :height, :z, :items

    def initialize opts = {}
      @rendered = false
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 100
      @height = opts[:height] || 122
      @items = opts[:items] || []
      @rendered_items = []
      @item_height = opts[:item_height] || 20
      @start_index = 0
      @end_index = [@items.count, ((@height - 2).to_f / @item_height).floor - 1].min
    end

    def remove
      @border.remove
      @content.remove
      @up.remove
      @down.remove
      @rendered_items.each { |ri| ri.remove }
    end

    def add
      if @rendered
        @border.add
        @content.add
        @up.add
        @down.add
      else
        render!
      end
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    def up
      if @start_index > 0
        @start_index -= 1
        @end_index -= 1

        render_items!
      end
    end

    def down
      if @end_index < @items.length - 1
        @start_index += 1
        @end_index += 1

        render_items!
      end
    end

    private

    def render_items!
      @rendered_items.each { |ri| ri.remove }

      y = @content.y

      @rendered_items[@start_index..@end_index].each do |ri|
        ri.x = @content.x
        ri.y = y
        ri.add
        y += @item_height
      end
    end

    def render!
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

      @up = Button.new(
        listener: self,
        z: @z,
        x: @x + @width,
        y: @y,
        width: 20,
        height: 20,
        label: '^',
        on_click: 'up'
      )

      @down = Button.new(
        listener: self,
        z: @z,
        x: @x + @width,
        y: @y + @up.height,
        width: 20,
        height: 20,
        label: 'v',
        on_click: 'down'
      )

      @up.add
      @down.add

      layout_items!

      @rendered = true
    end

    def layout_items!
      y = @content.y

      @items.each do |item|
        item_element = Label.new(
          text: item,
          z: @z,
          x: @content.x,
          y: y,
          width: @content.width,
          height: @item_height
        )

        y += @item_height

        item_element.add

        @rendered_items << item_element
      end

      render_items!
    end
  end
end
