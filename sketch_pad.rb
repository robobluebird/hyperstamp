module Ruby2D
  class SketchPad
    attr_reader :z, :x, :y, :width, :height, :cancel_button, :save_button

    def initialize opts = {}
      @pixel_x_offset = 0
      @pixel_y_offset = 0
      @color = 'black'
      @drawing = false
      @pixels = []
      @canvas_size = 256
      @visible = false
      @rendered = false
      @action = opts[:action].to_sym
      @listener = opts[:listener]
      @x = 0
      @y = 0
      @background_width = opts[:background_width]
      @background_height = opts[:background_height]
      @width = @background_width
      @height = @background_height
      @z = 4000
    end

    def export
      MiniMagick::Tool::Convert.new do |convert|
        convert.size '256x256'
        convert << 'xc:none'

        @pixels.each do |p|
          rgba = "rgba(#{(p.color.r * 255).to_i},#{(p.color.g * 255).to_i},#{(p.color.b * 255).to_i},#{p.color.a})"

          convert.fill rgba

          x = p.x - @canvas.x
          y = p.y - @canvas.y

          convert.draw "rectangle #{x},#{y} #{x + p.size},#{y + p.size}"
        end

        convert << 'export.png'
      end

      true
    end

    def objectify
      [self, @cancel_button, @save_button]
    end

    def cancel
      @listener.send :remove_sketch_pad
    end

    def save
      if export
        cancel
      else
        raise 'Failed to export'
      end
    end

    def translate x, y
    end

    def resize x, y
    end

    def contains? x, y
      (@x..(@x + @width)).cover?(x) &&
        (@y..(@y + @height)).cover?(y)
    end

    def visible?
      @visible
    end

    def remove
      @background.remove
      @border.remove
      @canvas.remove
      @cancel_button.remove
      @save_button.remove
      @pixels.each { |p| p.remove }
      @pixels = []

      @visible = false

      self
    end

    def add
      if @rendered
        @background.add
        @border.add
        @canvas.add
        @cancel_button.add
        @save_button.add
      else
        render!
      end

      @visible = true

      self
    end

    def hover_on x, y
      if @drawing && canvas?(x, y)
        maybe_draw x, y
      end
    end

    def hover_off x, y
    end

    def mouse_down x, y, button
      if canvas? x, y
        if button == :left
          @drawing = true
          maybe_draw x, y
        elsif button == :right
          if p = pixel?(x, y)
            p.remove
            @pixels.delete p
            puts @pixels.count
          end
        end
      end
    end

    def mouse_up x, y, button
      @drawing = false
    end

    def calc i
      ((i.to_f / 8).floor * 8)
    end

    def canvas? x, y
      (@canvas.x...(@canvas.x + @canvas.width)).cover?(x) &&
        (@canvas.y...(@canvas.y + @canvas.height)).cover?(y)
    end

    def pixel? x, y
      @pixels.find do |pixel|
        pixel.x == calc(x) + @pixel_x_offset &&
          pixel.y == calc(y) + @pixel_y_offset
      end
    end

    def pixel x, y
      { x: calc(x) + @pixel_x_offset, y: calc(y) + @pixel_y_offset }
    end

    def maybe_draw x, y
      return unless @drawing

      unless pixel? x, y
        p = pixel x, y
        p = p.merge size: 8, color: @color, z: @z

        @pixels << Square.new(p)
      end
    end

    private

    def render!
      @background = Rectangle.new(
        z: @z,
        x: 0,
        y: 0,
        width: @background_width,
        height: @background_height,
        color: 'white'
      )

      @background.opacity = 0.5

      @border = Border.new(
        z: @z,
        x: (@background_width / 2) - ((@canvas_size + 2) / 2),
        y: (@background_height / 2) - ((@canvas_size + 2) / 2),
        width: @canvas_size + 2,
        height: @canvas_size + 2,
      )

      cx = (@background_width / 2) - (@canvas_size / 2)
      cy = (@background_height / 2) - (@canvas_size / 2)

      @pixel_x_offset = cx % 8
      @pixel_y_offset = cy % 8

      @canvas = Rectangle.new(
        z: @z,
        x: cx,
        y: cy,
        width: @canvas_size,
        height: @canvas_size
      )

      @cancel_button = Button.new(
        z: @z,
        x: @canvas.x + (@canvas.width - 100 - 100 - 5),
        y: @canvas.y + @canvas.height + 5,
        height: 20,
        label: 'cancel',
        listener: self,
        action: 'cancel'
      ).add

      @save_button = Button.new(
        z: @z,
        x: @cancel_button.x + @cancel_button.width + 5,
        y: @canvas.y + @canvas.height + 5,
        height: 20,
        label: 'save',
        listener: self,
        action: 'save'
      ).add

      @rendered = true
    end
  end
end
