module Ruby2D
  class MenuItem
    attr_reader :width

    def initialize opts = {}
      @z = 2000
      @x = opts[:x]
      @y = opts[:y]
      @height = 20
      @elements = create_elements opts[:elements]

      hide_elements

      @background = Rectangle.new(
        x: @x,
        y: @y,
        width: 0,
        height: @height - 1,
        color: 'white',
        z: @z
      )

      @text = Text.new(
        x: @x,
        y: @y,
        text: opts[:text],
        color: 'black',
        font: 'fonts/lux.ttf',
        size: 12,
        z: @z
      )

      @width = @text.width + 20
      @text.x = @text.x + 10
      @background.width = @width
    end

    def element_at x, y
      @elements.find { |e| e.contains? x, y }
    end

    def invert
      @text.color = 'white'
      @background.color = 'black'
      show_elements
    end

    def revert
      @text.color = 'black'
      @background.color = 'white'
      hide_elements
    end

    def contains? x, y
      (@x..(@x + @width)).cover?(x) && (@y..(@y + @height)).cover?(y)
    end

    def show_elements
      @elements.each { |e| e.add }
    end

    def hide_elements
      @elements.each { |e| e.remove }
    end

    private

    def create_elements elements
      y = @height - 1 # to overlap borders

      elems = elements.map do |e|
        m = MenuElement.new x: @x, y: y, text: e[:text], on_click: e[:on_click]
        y += m.height - 1
        m
      end

      elems
    end
  end
end
