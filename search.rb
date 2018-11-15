module Ruby2D
  class Search
    attr_reader :z, :x, :y, :width, :height, :cancel_button, :search_button

    def initialize opts = {}
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

    def objectify
      [self, @search_field, @cancel_button, @search_button]
    end

    def cancel
      @listener.send :remove_search
    end

    def search
      # run a search
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
      @search_field.remove
      @cancel_button.remove
      @search_button.remove

      @visible = false

      self
    end

    def add
      if @rendered
        @background.add
        @search_field.add
        @cancel_button.add
        @search_button.add
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

      @search_field = Field.new(
        tag: 'search',
        text: '',
        z: @z,
        x: @background_width / 2 - 50,
        y: @background_height / 2 - 50,
        width: 100,
        height: 50,
        font: { size: 32 }
      ).add

      @cancel_button = Button.new(
        z: @z,
        x: @background_width / 2,
        y: @background_height / 2 + 50,
        height: 20,
        label: 'cancel',
        listener: self,
        action: 'cancel'
      ).add

      @search_button = Button.new(
        z: @z,
        x: @cancel_button.x + @cancel_button.width + 5,
        y: @background_height / 2 + 50,
        height: 20,
        label: 'save',
        listener: self,
        action: 'save'
      ).add

      @rendered = true
    end
  end
end
