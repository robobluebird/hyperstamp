module Ruby2D
  class MenuItem
    attr_reader :x, :y, :width, :height, :z, :active

    def initialize opts = {}
      extend Ruby2D::DSL

      @events_enabed = false
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

    def add
      if @rendered
        @background.add
        @text.add

        events!
      else
        render!
      end

      self
    end

    def remove
      @background.remove
      @text.remove

      if @events_enabled
        off @mouse_down_event
        off @mouse_up_event
        @events_enabled = false
      end

      self
    end

    def active= state
      if state
        @text.color = 'black'
        events!
      else
        @text.color = 'gray'
        off @mouse_down_event
        off @mouse_up_event
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

      @elements = create_elements @elements_

      hide_elements

      events!

      @rendered = true
    end

    def events!
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

      @events_enabled = true
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
