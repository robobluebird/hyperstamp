module Ruby2D
  class Editor
    attr_reader :z, :x, :y, :width, :height, :object, :cancel_button, :save_button

    def initialize opts = {}
      @editor_size = 256
      @visible = false
      @rendered = false
      @listener = opts[:listener]
      @x = 0
      @y = 0
      @background_width = opts[:background_width]
      @background_height = opts[:background_height]
      @width = @background_width
      @height = @background_height
      @z = 4000
      @object = opts[:object]
    end

    def cancel
      @listener.send :remove_editor
    end

    def save
      new_label = @label_field.text
      @object.label = new_label
      @label_field.text = ''

      cancel
    end

    def objectify
      [self, @label_field, @cancel_button, @save_button]
    end

    def translate x, y; end

    def resize x, y; end

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
      @editor.remove
      @cancel_button.remove
      @save_button.remove
      @label_field.remove
      @label_label.remove

      @visible = false

      self
    end

    def add
      if @rendered
        @background.add
        @border.add
        @editor.add
        @cancel_button.add
        @save_button.add
      else
        render!
      end

      @visible = true

      self
    end

    def hover_on x, y

    end

    def hover_off x, y

    end

    def mouse_down x, y, button

    end

    def mouse_up x, y, button

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
        x: (@background_width / 2) - ((@editor_size + 2) / 2),
        y: (@background_height / 2) - ((@editor_size + 2) / 2),
        width: @editor_size + 2,
        height: @editor_size + 2,
      )

      cx = (@background_width / 2) - (@editor_size / 2)
      cy = (@background_height / 2) - (@editor_size / 2)

      @pixel_x_offset = cx % 8
      @pixel_y_offset = cy % 8

      @editor = Rectangle.new(
        z: @z,
        x: cx,
        y: cy,
        width: @editor_size,
        height: @editor_size
      )

      @label_label = Label.new(
        text: 'label',
        z: @z,
        x: @editor.x + 10,
        y: @editor.y,
        width: 100,
        height: 20
      ).add

      @label_field = Field.new(
        text: @object.label,
        z: @z,
        x: @editor.x + 10,
        y: @editor.y + 20,
        width: 100,
        height: 20,
        font: { size: 12 }
      ).add

      @cancel_button = Button.new(
        z: @z,
        x: @editor.x + (@editor.width - 100 - 100 - 5),
        y: @editor.y + @editor.height + 5,
        height: 20,
        label: 'cancel',
        listener: self,
        action: 'cancel'
      ).add

      @save_button = Button.new(
        z: @z,
        x: @cancel_button.x + @cancel_button.width + 5,
        y: @editor.y + @editor.height + 5,
        height: 20,
        label: 'save',
        listener: self,
        action: 'save'
      ).add

      @rendered = true
    end
  end
end
