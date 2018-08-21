module Ruby2D
  class Field
    attr_reader :words, :text_color, :color_scheme, :style, :x, :y, :width, :height, :z
    attr_accessor :tag

    def initialize opts = {}
      @shifted = false
      @tag = opts[:tag] || opts['tag']
      @lines = []
      @words = opts[:text] || opts['text']
      @text_color = (opts[:text_color] || opts['text_color'] || :black).to_sym

      @z      = opts[:z] || opts['z']
      @x      = opts[:x] || opts['x']
      @y      = opts[:y] || opts['y']
      @width  = opts[:width] || opts['width']
      @height = opts[:height] || opts['height']

      @font = Font.new(
        type: (opts.dig(:font, :type) || :lux).to_sym,
        size: opts.dig(:font, :size)
      )

      @cursor = Line.new(
        z: @z,
        x1: 0,
        y1: 0,
        x2: 0,
        y2: @font.height,
        color: 'black'
      )

      @focus = Border.new(
        z: @z,
        thickness: 5,
        x: @x - 5,
        y: @y - 5,
        width: @width + 10,
        height: @height + 10,
        color: 'blue'
      )

      @focus.hide

      @border = Border.new(
        z: @z,
        x: @x,
        y: @y,
        width: @width,
        height: @height,
        thickness: 1,
        color: 'black'
      )

      @content = Rectangle.new(
        z: @z,
        x: @x + @border.thickness,
        y: @y + @border.thickness,
        width: @width - (@border.thickness * 2),
        height: @height - (@border.thickness * 2),
        color: 'white'
      )

      self.style = (opts[:style] || opts['style'] || :opaque).to_sym
      self.color_scheme = (opts[:color_scheme] || opts['color_scheme'] || :black_on_white).to_sym
      @cursor.opacity = 0

      arrange_text!
    end

    def to_h
      {
        type: 'field',
        tag: @tag,
        text: @words,
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

    def contains? x, y
      (@x..(@x + @width)).cover?(x) && (@y..(@y + @height)).cover?(y)
    end

    def z= new_z
      @z = new_z
      @cursor.z = new_z
      @focus.z = new_z
      @border.z = new_z
      @content.z = new_z
      @lines.each { |line| line.z = new_z }
    end

    def editable?
      true
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

    def append str
      if ['up', 'down', 'left', 'right'].include? str
        # move cursor and insert at
        # @words.length - cursor vert and horz position
      elsif str.include? 'backspace'
        @words.slice! -1
      elsif str.include? 'return'
        @words += "\n"
      elsif str.include? 'space'
        @words += ' '
      elsif str.include? 'capslock'
        @shifted = !@shifted
      else
        elements = str.to_s.split('_')
        @words += Keys.get(elements.last, @shifted || elements.count == 2)
      end

      arrange_text!
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
      @focus.resize dx, dy

      @content.width = @content.width + dx
      @content.height = @content.height + dy

      arrange_text!
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @border.translate dx, dy
      @focus.translate dx, dy

      @content.x = @content.x + dx
      @content.y = @content.y + dy

      arrange_text!
    end

    def focus
      @cursor.opacity = 1
      @focus.show
    end

    def defocus
      @cursor.opacity = 0
      @focus.hide
    end

    private

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
      newline_count = @words.count("\n")
      character_count = @words.length - newline_count

      n = @words.split("\n").reduce(0) do |memo, item|
        memo += [(item.length.to_f / chars_across).ceil, 1].max
      end

      i = -1
      while @words[i] == "\n"
        n += 1
        i -= 1
      end

      num_lines = [n, (@content.height.to_f / @font.height).floor].min

      start_index = 0

      num_lines.times do |line_num|
        next_linebreak = @words.index("\n", start_index)

        options = [
          start_index + chars_across
        ]

        options << next_linebreak if next_linebreak

        end_index = options.min

        range = start_index...end_index

        @lines << Text.new(
          color: @text_color.to_s,
          z: @z,
          text: @words[range] || '',
          font: @font.file,
          size: @font.size.to_i,
          x: @content.x,
          y: @content.y + line_num * @font.height
        )

        start_index = next_linebreak ? end_index + 1 : end_index
      end

      @cursor.z = @z
      @cursor.x1 = @content.x + (@lines.last ? @lines.last.text.length : 0) * @font.width
      @cursor.x2 = @cursor.x1
      @cursor.y1 = @content.y + (num_lines.zero? ? 0 : num_lines - 1) * @font.height
      @cursor.y2 = @content.y + (num_lines.zero? ? 1 : num_lines) * @font.height
    end
  end
end
