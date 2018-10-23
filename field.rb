module Ruby2D
  class Field
    attr_reader :font, :text_color, :color_scheme, :style, :x, :y, :width, :height, :z
    attr_accessor :tag

    CursorPosition = Struct.new :line, :column

    def initialize opts = {}
      @bordered = opts[:bordered].nil? ? true : opts[:bordered]
      @cursor_position = CursorPosition.new 0, 0
      @visible = false
      @rendered = false
      @shifted = false
      @tag = opts[:tag]
      @lines = []
      @characters = opts[:text].split('') || []
      @text_color = (opts[:text_color] || :black).to_sym
      @style = (opts[:style] || :opaque).to_sym
      @color_scheme = (opts[:color_scheme] || :black_on_white).to_sym
      @insert_index = @characters.count

      @z      = opts[:z] || 0
      @x      = opts[:x] || 0
      @y      = opts[:y] || 0
      @width  = opts[:width] || 100
      @height = opts[:height] || 100

      @font = Font.new(
        type: opts.dig(:font, :type),
        size: opts.dig(:font, :size)
      )
    end

    def configurable?
      true
    end

    def text
      @characters.join
    end

    def text= new_text
      @characters = new_text.split ''
      @insert_index = @characters.count

      arrange_text!
    end

    def text_size= size
      @font.size = size

      arrange_text!

      size
    end

    def to_h
      {
        type: 'field',
        tag: @tag,
        text: @characters.join,
        x: @x,
        y: @y,
        width: @width,
        height: @height,
        style: @style,
        color_scheme: @color_scheme,
        font: {
          type: @font.type,
          size: @font.size.to_s
        }
      }
    end

    def visible?
      @visible
    end

    def bordered?
      @bordered
    end

    def remove
      clear_text!

      @highlight.remove
      @border.remove
      @content.remove
      @cursor.remove

      @visible = false

      self
    end

    def add
      if @rendered
        @highlight.add
        @border.add if bordered?
        @content.add
        arrange_text!
        @cursor.add
        defocus
      else
        render!
      end

      @visible = true

      self
    end

    def contains? x, y
      (@content.x..(@content.x + @content.width)).cover?(x) &&
        (@content.y..(@content.y + @content.height)).cover?(y)
    end

    def z= new_z
      @z = new_z
      @cursor.z = new_z
      @highlight.z = new_z
      @border.z = new_z
      @content.z = new_z
      @lines.each { |line| line.z = new_z }
    end

    def editable?
      true
    end

    def append str
      if ['up', 'down', 'left', 'right'].include? str
        if str == 'left'
          @insert_index -= 1 if @insert_index > 0
        elsif str == 'right'
          @insert_index += 1 if @insert_index < @characters.count
        elsif str == 'up'
          # @cursor_position.line -= 1
        else str == 'down'
          # @cursor_position.line += 1
        end

        position_cursor

        return
      elsif str.include? 'backspace'
        if @insert_index > 0
          @insert_index -= 1
          @characters.delete_at @insert_index
        end
      elsif str.include? 'return'
        @characters.insert @insert_index, "\n"
        @insert_index += 1
      elsif str.include? 'space'
        @characters.insert @insert_index, ' '
        @insert_index += 1
      elsif str.include? 'capslock'
        @shifted = !@shifted
      else
        elements = str.to_s.split('_')

        if elements.include? 'command'
          # noop, these should be caught at a higher level i think??
        else
          char = Keys.get elements.last, @shifted || elements.count == 2

          @characters.insert @insert_index, char if char

          @insert_index += 1
        end
      end

      arrange_text!
    end

    def style= style
      case style
      when :opaque
        @border.show
        @content.opacity = 1
      when :transparent
        @border.hide
        @content.opacity = 0
      else
        raise
      end

      @style = style
    end

    def color_scheme= scheme
      raise unless [:black_on_white, :white_on_black].include? scheme

      case scheme
      when :black_on_white
        @border.color = 'black'
        @content.color = 'white'
        @text_color = 'black'
        @cursor.color = 'black'
      when :white_on_black
        @border.color = 'white'
        @content.color = 'black'
        @text_color = 'white'
        @cursor.color = 'white'
      end

      @color_scheme = scheme
      arrange_text!
      self.style = @style
    end

    def text_color= color
      raise unless [:black, :white].include? color

      @text_color = color

      arrange_text!
    end

    def resize dx, dy
      @width = @width + dx
      @height = @height + dy

      @border.resize dx, dy
      @highlight.resize dx, dy

      @content.width = @content.width + dx
      @content.height = @content.height + dy

      arrange_text!
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @border.translate dx, dy
      @highlight.translate dx, dy

      @content.x = @content.x + dx
      @content.y = @content.y + dy

      arrange_text!
    end

    def highlight
      @highlight.show
    end

    def unhighlight
      @highlight.hide
    end

    def focus
      @cursor.add
    end

    def defocus
      @cursor.remove
    end

    def hover_on x, y
    end

    def hover_off x, y
    end

    def mouse_up x, y, button
    end

    def mouse_down x, y, button
    end

    private

    def render!
      @highlight = Border.new(
        z: @z,
        thickness: 5,
        x: @x - 5,
        y: @y - 5,
        width: @width + 10,
        height: @height + 10,
        color: 'black'
      )

      @highlight.hide

      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height,
        thickness: 1,
        color: 'black'
      )

      @border.remove unless bordered?

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2),
        color: 'white'
      )

      @cursor = Line.new(
        z: @z,
        x1: 0,
        y1: 0,
        x2: 0,
        y2: @font.height,
        color: 'black'
      )

      style = @style
      color_scheme = @color_scheme

      arrange_text!
      defocus

      @rendered = true
    end

    def clear_text!
      @lines.each do |l|
        l.remove
      end

      @lines.clear
    end

    def arrange_text!
      clear_text!

      return if @content.width < @font.width

      chars_across = (@content.width.to_f / @font.width).floor

      # for each segment between newline chars,
      # divide the number of chars in the segment by the number
      # of chars we can display in the line
      # if the segment char count doesn't fit then we need potentially multiple
      # more newlines inbetween the newline chars
      number_of_newlines = @characters.join.split("\n").reduce(0) do |memo, item|
        memo += [(item.length.to_f / chars_across).ceil, 1].max
      end

      number_of_newlines = 1 if number_of_newlines == 0

      # consider multiple newlines at the end of the text
      i = -1
      while @characters[i] == "\n"
        number_of_newlines += 1
        i -= 1
      end

      number_of_lines = [number_of_newlines, (@content.height.to_f / @font.height).floor].min

      start_index = 0

      number_of_lines.times do |line_num|
        next_linebreak = nil

        i = start_index
        while i < @characters.length
          if @characters[i] == "\n"
            next_linebreak = i
            break
          end

          i += 1
        end

        options = [
          start_index + chars_across
        ]

        options << next_linebreak if next_linebreak

        end_index = options.min

        range = start_index...end_index

        @lines << Text.new(
          color: @text_color.to_s,
          z: @z,
          text: @characters[range].join || '',
          font: @font.file,
          size: @font.size.to_i,
          x: @content.x,
          y: @content.y + line_num * @font.height
        )

        start_index = next_linebreak ? end_index + 1 : end_index
      end

      # @cursor_position.column = @lines.last ? @lines.last.text.length : 0
      # @cursor_position.line = number_of_lines - 1

      position_cursor
    end

    def position_cursor
      line = 0
      column = 0
      line_character_counter = 0
      character_counter = 0
      line_length = (@content.width.to_f / @font.width).floor

      @characters.each_with_index do |character, index|
        break if character_counter == @insert_index

        line_character_counter += 1

        if character == "\n" || line_character_counter > line_length
          line += 1

          column = 0

          line_character_counter = 0
        else
          column += 1
        end

        character_counter += 1
      end

      @cursor_position.line = line
      @cursor_position.column = column

      @cursor.x1 = @content.x + @cursor_position.column * @font.width
      @cursor.x2 = @cursor.x1
      @cursor.y1 = @content.y + @cursor_position.line * @font.height
      @cursor.y2 = @content.y + (@cursor_position.line + 1) * @font.height
    end
  end
end
