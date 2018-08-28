module Ruby2D
  class Label
    attr_reader :x, :y, :z, :width, :height, :words

    def initialize opts = {}
      extend Ruby2D::DSL

      @hovered = false
      @click1 = nil
      @rendered = false
      @events_enabled = false

      @listener = opts[:listener]
      @action = opts[:action]
      @z = opts[:z] || 0
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @width = opts[:width] || 0
      @height = opts[:height] || 0
      @words = opts[:text] || 'label'

      @font = Font.new(
        type: (opts.dig(:font, :type) || :lux).to_sym,
        size: opts.dig(:font, :size) || 12
      )
    end

    def remove
      raise "Can't remove before being added" unless @rendered

      @highlight.remove
      @content.remove
      @text.remove

      if @events_enabled
        off @hover_event
        off @click_event

        @events_enabled = false
      end

      true
    end

    def add
      if @rendered
        @highlight.add
        @content.add
        @text.add

        events!
      else
        render!
      end
    end

    def resize dx, dy
      @width = @width + dx
      @height = @height + dy

      @highlight.resize dx, dy

      @content.width = @content.width + dx
      @content.height = @content.height + dy

      arrange_text!
    end

    def x= x
      @x = x
      @highlight.move_to @x, @y
      @content.x = @x
      arrange_text!
    end

    def y= y
      @y = y
      @highlight.move_to @x, @y
      @content.y = @y
      arrange_text!
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @content.x = @content.x + dx
      @content.y = @content.y + dy

      @highlight.translate dx, dy

      @text.x = @text.x + dx
      @text.y = @text.y + dy
    end

    def highlight
      @highlight.show
    end

    def unhighlight
      @highlight.hide
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    def invert
      @content.color = "black"
      @text.color = "white"
      @hovered = true
    end

    def revert
      @content.color = "white"
      @text.color = "black"
      @hovered = false
    end

    private

    def events!
      @hover_event = on :mouse_move do |e|
        if @rendered
          if @content.contains?(e.x, e.y)
            invert
          elsif @hovered
            revert
          end
        end
      end

      @click_event = on :mouse_up do |e|
        if @rendered
          if @click1 && @content.contains?(e.x, e.y) && Time.now.to_f - @click1 < 0.20
            if @listener && @action
              @listener.instance_eval @action
            end

            @click1 = nil
          elsif @content.contains? e.x, e.y
            @click1 = Time.now.to_f
          end
        end
      end

      @events_enabled = true
    end

    def render!
      @highlight = Border.new(
        z: @z,
        x: @x - 5,
        y: @y - 5,
        width: @width + 10,
        height: @height + 10,
        thickness: 5,
        color: 'blue'
      )

      @highlight.hide

      @content = Rectangle.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height
      )

      @text = Text.new(
        z: @z,
        x: @x,
        text: @words,
        font: @font.file,
        size: @font.size.to_i,
        color: 'black'
      )

      @width = @text.width if @width.zero?
      @height = @text.height if @height.zero?

      @highlight.resize_to @width + 10, @height + 10

      @content.width = @width
      @content.height = @height

      arrange_text!

      events!

      @rendered = true
    end

    def arrange_text!
      @text.y = @y + (@height / 2) - @text.height / 2
    end
  end
end
