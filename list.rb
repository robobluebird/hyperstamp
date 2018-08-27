module Ruby2D
  class List
    attr_reader :x, :y, :width, :height, :z, :items

    def initialize opts = {}
      extend Ruby2D::DSL

      @rendered = false
      @mouse_over = false
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
      @rendered_items.each { |ri| ri.remove }
    end

    def add
      if @rendered
        @border.add
        @content.add
      else
        render!
      end
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    def scroll change
      change = change.to_i

      change = if change > 0
                 [change, @items.length - 1 - @end_index].min
               elsif change < 0
                 [change, 0 - @start_index].max
               else
                 0
               end

      @start_index += change
      @end_index += change

      render_items!
    end

    def choose item
      pp item
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

    def select item
      p item
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

      layout_items!

      @mouse_move = on :mouse_move do |e|
        if @rendered
          if @content.contains? e.x, e.y
            @mouse_over = true
            @last_mouse_x = e.x
            @last_mouse_y = e.y
          elsif @mouse_over
            @mouse_over = false
            @last_mouse_x = nil
            @last_mouse_y = nil
          end
        end
      end

      @mouse_scroll = on :mouse_scroll do |e|
        if @rendered && @mouse_over
          scroll e.delta_y

          @rendered_items.each do |ri|
            if ri.contains? @last_mouse_x, @last_mouse_y
              ri.invert
            else
              ri.revert
            end
          end
        end
      end

      @rendered = true
    end

    def layout_items!
      y = @content.y

      @items.each.with_index do |item|
        item_element = Label.new(
          listener: self,
          action: "choose '#{item}'",
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
