module Ruby2D
  class Menu
    attr_reader :items

    def initialize opts = {}
      @listener = opts[:listener]
      @z = 2000
      @x = 0
      @y = 0
      @width = opts[:width]
      @height = 20

      @border = Border.new(
        color: 'black',
        height: @height,
        width: @width,
        x: @x,
        y: @y,
        z: @z,
        only: :bottom
      )

      @background = Rectangle.new(
        color: 'white',
        height: @height - 1,
        width: @width,
        x: @x,
        y: @y,
        z: @z
      )

      self.items
    end

    def items
      @items ||= begin
        x = 20

        File.open('menu/menu.json') do |f|
          JSON.parse(f.read, symbolize_names: true).map do |item|
            item.merge(x: @x, y: @y, height: @height, width: @width)
          end.map do |elem_rep|
            m = MenuItem.new elem_rep.merge(x: x, listener: @listener)
            x += m.width
            m
          end
        end
      end
    end

    private

    def clear!
      @items.map(&:destroy)
    end
  end
end
