module Ruby2D
  class MenuItem
    attr_reader :x, :y, :width, :height, :z, :active, :elements

    def initialize opts = {}
      @visible = false
      @active = true
      @open = false
      @listener = opts[:listener]
      @z = 2000
      @x = opts[:x]
      @y = opts[:y]
      @words = opts[:text]
      @height = 20
      @elements_ = opts[:elements] || []
      @elements = []
    end

    def visible?
      @visible
    end

    def add
      if @rendered
        @background.add
        @text.add
      else
        render!
      end

      @visible = true

      self
    end

    def remove
      @background.remove
      @text.remove

      @visible = false

      self
    end

    def active= state
      if state
        @text.color = 'black'
      else
        @text.color = 'gray'
      end

      @active = state
    end

    def active?
      @active
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
      (@background.x..(@background.x + @background.width)).cover?(x) &&
        (@background.y..(@background.y + @background.height)).cover?(y)
    end

    def show_elements
      @elements.each { |e| e.add }
    end

    def hide_elements
      @elements.each { |e| e.remove }
    end

    def mouse_down x, y
      if @active
        invert
        @open = true
      end
    end

    def mouse_up x, y
      if @open
        revert
        @open = false
      end
    end

    def hover_on x, y
    end

    def hover_off x, y
    end

    private

    def render!
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
        text: @words,
        color: 'black',
        font: 'fonts/lux.ttf',
        size: 12,
        z: @z
      )

      @width = @text.width + 20
      @text.x = @text.x + 10
      @background.width = @width

      @elements = create_elements @elements_

      hide_elements

      @rendered = true
    end

    def create_elements elements
      y = @height - 1 # to overlap borders

      elems = elements.map do |e|
        m = MenuElement.new(
          listener: @listener,
          x: @x,
          y: y,
          text: e[:text],
          action: e[:action]
        )

        y += m.height - 1

        m
      end

      elems
    end
  end
end
