module Ruby2D
  class MenuItem
    attr_reader :x, :y, :width, :height, :z, :active

    def initialize opts = {}
      extend Ruby2D::DSL

      @active = true
      @open = false
      @listener = opts[:listener]
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

      @mouse_down_event = on :mouse_down do |e|
        if @active && contains?(e.x, e.y)
          invert
          @open = true
        end
      end

      @mouse_up_event = on :mouse_up do |e|
        if @open
          revert
          @open = false
        end
      end
    end

    def active= state
      if state
        @text.color = 'gray'
        off(@mouse_down_event)
      else
        @text.color = 'black'
        off(@mouse_down_event)
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

    private

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
