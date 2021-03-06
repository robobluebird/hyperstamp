module Ruby2D
  class Editor
    attr_reader :z, :x, :y, :width, :height, :cancel_button, :save_button
    attr_accessor :object

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
      @settings = []
    end

    def cancel
      @listener.send :remove_editor
    end

    def save
      if @label_field
        new_label = @label_field.text
        @object.label = new_label
      end

      if @size_checklist
        new_size = @size_checklist.checked
        @object.text_size = new_size.to_i if new_size
      end

      if @bordered_checklist
        bordered = @bordered_checklist.checked
        @object.bordered = {yes: true, no: false}[bordered.to_sym]
      end

      if @dashed_checklist
        dashed = @dashed_checklist.checked
        @object.dashed = {yes: true, no: false}[dashed.to_sym]
      end

      if @tag_field
        new_tag = @tag_field.text
        @object.tag = new_tag
      end

      if @script_field
        new_script = @script_field.text
        @object.script = new_script
      end

      cancel
    end

    def objectify
      list = [self, @cancel_button, @save_button]
      list << @label_field if @label_field
      list << @size_checklist if @size_checklist
      list << @bordered_checklist if @bordered_checklist
      list << @dashed_checklist if @dashed_checklist
      list << @tag_field if @tag_field
      list << @script_field if @script_field
      list
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

      if @label_field
        @label_field.remove
        @label_label.remove
      end

      if @size_checklist
        @size_checklist.remove
        @size_label.remove
      end

      if @bordered_checklist
        @bordered_checklist.remove
        @bordered_label.remove
      end

      if @dashed_checklist
        @dashed_checklist.remove
        @dashed_label.remove
      end

      if @tag_field
        @tag_field.remove
        @tag_label.remove
      end

      if @script_field
        @script_label.remove
        @script_field.remove
      end

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

        if @label_field
          @label_field.text = @object.label
          @label_field.add
          @label_label.add
        end

        if @size_checklist
          @size_checklist.add
          @size_checklist.checked = @object.font.size.to_s
          @size_label.add
        end

        if @bordered_checklist
          @bordered_checklist.add
          @bordered_checklist.checked = @object.bordered? ? 'yes' : 'no'
          @bordered_label.add
        end

        if @dashed_checklist
          @dashed_checklist.add
          @dashed_checklist.checked = @object.dashed? ? 'yes' : 'no'
          @dashed_label.add
        end

        if @tag_field
          @tag_field.text = @object.tag
          @tag_field.add
          @tag_label.add
        end

        if @script_field
          @script_field.text = @object.script
          @script_field.add
          @script_label.add
        end
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

    def scriptable?
      @object && @object.respond_to?(:script)
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

      border_offset = @editor_size / 2 + 2
      border_offset = @editor_size + 1 if scriptable?

      border_x = (@background_width / 2) - border_offset

      border_width = scriptable? ? (@editor_size * 2) + 2 : @editor_size + 2

      @border = Border.new(
        z: @z,
        x: border_x,
        y: (@background_height / 2) - ((@editor_size + 2) / 2),
        width: border_width,
        height: @editor_size + 2,
      )

      editor_offset = @editor_size / 2
      editor_offset = editor_offset * 2 if scriptable?

      cx = (@background_width / 2) - editor_offset
      cy = (@background_height / 2) - (@editor_size / 2)

      @pixel_x_offset = cx % 8
      @pixel_y_offset = cy % 8

      @editor = Rectangle.new(
        z: @z,
        x: cx,
        y: cy,
        width: scriptable? ? @editor_size * 2 : @editor_size,
        height: @editor_size
      )

      y_offset = 0

      if @object.respond_to? :label=
        @label_label = Label.new(
          text: 'label',
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          width: @editor_size - 20,
          height: 20
        ).add

        y_offset += 20

        @label_field = Field.new(
          dashed: false,
          text: @object.label,
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          width: @editor_size - 20,
          height: 20,
          font: { size: 12 }
        ).add

        y_offset += 20

        @settings += [@label_label, @label_field]
      end

      if @object.respond_to? :text_size=
        @size_label = Label.new(
          text: 'size',
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          width: @editor_size - 20,
          height: 20
        ).add

        y_offset += 20

        @size_checklist = Checklist.new(
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          suggested_width: @editor_size,
          items: ['8', '12', '16', '20', '24', '32', '64', '128']
        ).add

        @size_checklist.checked = @object.font.size.to_s

        y_offset += @size_checklist.height

        @settings += [@size_label, @size_checklist]
      end

      if @object.respond_to? :bordered=
        @bordered_label = Label.new(
          text: 'border?',
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          height: 20
        ).add

        y_offset += 20

        @bordered_checklist = Checklist.new(
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          items: ['yes', 'no']
        ).add

        @bordered_checklist.checked = @object.bordered? ? 'yes' : 'no'

        y_offset += 20

        @settings += [@bordered_label, @bordered_checklist]
      end

      if @object.respond_to? :dashed=
        @dashed_label = Label.new(
          text: 'dashed?',
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          height: 20
        ).add

        y_offset += 20

        @dashed_checklist = Checklist.new(
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          items: ['yes', 'no']
        ).add

        @dashed_checklist.checked = @object.dashed? ? 'yes' : 'no'

        y_offset += 20

        @settings += [@dashed_label, @dashed_checklist]
      end

      if @object.respond_to? :tag
        @tag_label = Label.new(
          text: 'tag',
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          height: 20
        ).add

        y_offset += 20

        @tag_field = Field.new(
          dashed: false,
          text: @object.tag || '',
          z: @z,
          x: @editor.x + 10,
          y: @editor.y + y_offset,
          width: @editor_size - 20,
          height: 20,
          font: { size: 12 }
        ).add

        y_offset += 20

        @settings += [@tag_label, @tag_field]
      end

      if @object.respond_to? :script
        @script_label = Label.new(
          text: 'script',
          z: @z,
          x: @editor.x + @editor_size + 10,
          y: @editor.y,
          height: 20
        ).add

        y_offset += 20

        @script_field = Field.new(
          dashed: false,
          text: @object.script,
          z: @z,
          x: @editor.x + @editor_size + 10,
          y: @editor.y + 20,
          width: @editor_size - 20,
          height: @editor_size - 40,
          font: { size: 12 }
        ).add

        y_offset += 20

        @settings += [@script_label, @script_field]
      end

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
