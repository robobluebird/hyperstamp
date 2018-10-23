module Ruby2D
  class FileCabinet
    attr_reader :z

    def initialize opts = {}
      @save = opts[:save].nil? ? false : opts[:save]
      @visible = false
      @path = Dir.pwd
      @rendered = false
      @intent = opts[:intent]
      @extension = opts[:extension]
      @action = opts[:action].to_sym
      @listener = opts[:listener]
      @background_width = opts[:background_width]
      @background_height = opts[:background_height]
      @x = 0
      @y = 0
      @width = @background_width
      @height = @background_height
      @z = 4000
    end

    def save?
      @save
    end

    def save
      if @name_field.text.length > 0
        name = @name_field.text.strip

        path = "#{@path}/#{name}.#{@extension}"

        @listener.send :remove_file_cabinet

        @listener.send @action, name, path
      end
    end

    def cancel
      @listener.send :remove_file_cabinet
    end

    def objectify
      objects = [self, @cancel_button] + @list.objectify

      objects.push @save_button if @save_button

      objects.push @name_field if @name_field

      objects
    end

    def visible?
      @visible
    end

    def remove
      @background.remove
      @list.remove
      @cancel_button.remove
      @save_button.remove if @save_button

      if @name_field
        @name_label.remove
        @name_field.remove
      end

      @visible = false

      self
    end

    def add
      if @rendered
        @background.add
        @list.add
        @cancel_button.add
        @save_button.add if @save_button

        if @name_field
          @name_label.add
          @name_field.text = ''
          @name_field.add
        end
      else
        render!
      end

      @visible = true

      self
    end

    def choose item
      if item.end_with? '/'
        item = item.split('/').first

        @path = File.expand_path(File.join(@path, item))

        if Dir.exist? @path
          old = @list.rendered_items.dup

          @list.items = entries

          new = @list.rendered_items

          @listener.send :replace_objects, old, new
        else
          raise 'dir'
        end
      elsif !save?
        FileMagic.mime { |fm|
          path = File.expand_path(File.join(@path, item))

          if @intent
            if fm.file(path).match(/^#{Regexp.quote(@intent.to_s)}/).nil?
              raise "File type doesn't match requirement of '#{@intent}'"
            end
          elsif @extension
            if path.split('.').last != @extension
              raise "File extension doesn't match requirement of '#{@extension}'"
            end
          end

          @listener.send @action, path if @listener && @action
        }
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

      @list = List.new(
        listener: self,
        z: 4000,
        x: (@background_width / 2) - (@background_width / 4),
        y: (@background_height / 2) - (@background_height / 4),
        width: @background_width / 2,
        height: @background_height / 2 + 2,
        items: entries
      ).add

      x = @list.x + (@list.width - 100)
      y = @list.y + @list.height + 5


      if save?
        @name_label = Label.new(
          text: "name (.#{@extension})",
          z: @z,
          x: @list.x,
          y: @list.y - 45,
          width: 100,
          height: 20
        ).add

        @name_field = Field.new(
          text: '',
          z: @z,
          x: @list.x,
          y: @list.y - 25,
          width: @list.width,
          height: 20,
          font: { size: 12 }
        ).add

        @save_button = Button.new(
          z: @z,
          x: x,
          y: y,
          height: 20,
          label: 'save',
          listener: self,
          action: 'save'
        ).add

        x = x - 105
      end

      @cancel_button = Button.new(
        z: @z,
        x: x,
        y: y,
        height: 20,
        label: 'cancel',
        listener: self,
        action: 'cancel'
      ).add

      @rendered = true
    end
  end

  def entries
    Dir.entries(@path).reject do |e|
      ['.', '.DS_Store'].include?(e)
    end.map do |e|
      Dir.exist?("#{@path}/#{e}") ? "#{e}/" : e
    end
  end
end
