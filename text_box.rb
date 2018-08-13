require 'ruby2d'
require_relative 'keys'

module Ruby2D
  class TextBox < Rectangle
    attr_reader :words, :text_color, :color_scheme, :style
    attr_accessor :tag

    def initialize opts = {}
      @shifted = false
      @show_border = true
      @tag = opts[:tag]
      @lines = []
      @words = opts[:text]
      @text_color = :black
      @color_scheme = :black_on_white
      @style = :default

      @cursor = Line.new(
        z: opts[:z],
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 16,
        color: 'black')

      @cursor.opacity = 0

      @focus = Rectangle.new(
        z: opts[:z],
        x: opts[:x] - 5,
        y: opts[:y] - 5,
        width: opts[:width] + 10,
        height: opts[:height] + 10,
        color: 'blue')

      @focus.opacity = 0

      @border = Rectangle.new(
        z: opts[:z],
        x: opts[:x] - 1,
        y: opts[:y] - 1,
        width: opts[:width] + 2,
        height: opts[:height] + 2,
        color: 'black')

      super opts

      arrange_text!
    end

    def z= new_z
      @cursor.z = new_z
      @focus.z = new_z
      @border.z = new_z
      super new_z
      @lines.each { |line| line.z = new_z }
    end

    def editable?
      true
    end

    def style= style
      case style
      when :default
        @border.opacity = 1
        self.opacity = 1
      when :text_only
        @border.opacity = 0
        self.opacity = 0
      else
        raise
      end

      @style = style
    end

    def append str
      if str.include? 'backspace'
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
        self.color = 'white'
        @text_color = 'black'
      when :white_on_black
        @border.color = 'white'
        self.color = 'black'
        @text_color = 'white'
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

    # def invert
    #   self.color = 'black'
    #   @border.color = 'white'
    #   @text_color = 'white'
    #   arrange_text!
    # end
    #
    # def revert
    #   self.color = 'white'
    #   @border.color = 'black'
    #   @text_color = 'black'
    #   arrange_text!
    #   self.style = @style
    #   self.color_scheme = @color_scheme
    # end

    def resize dx, dy
      self.width = @width + dx
      self.height = @height + dy

      resize!
      arrange_text!
    end

    def translate dx, dy
      self.x = @x + dx
      self.y = @y + dy

      @border.x = @border.x + dx
      @border.y = @border.y + dy

      @focus.x = @focus.x + dx
      @focus.y = @focus.y + dy

      arrange_text!
    end

    def focus
      @cursor.opacity = 1
      @focus.opacity = 1
    end

    def defocus
      @cursor.opacity = 0
      @focus.opacity = 0
    end

    private

    def resize!
      @border.width = self.width + 2
      @border.height = self.height + 2
      @focus.width = self.width + 10
      @focus.height = self.height + 10
    end

    def clear_text!
      @lines.each do |l|
        l.remove
      end

      @lines.clear
    end

    def arrange_text!
      clear_text!

      return if self.width < 7

      chars_across = (self.width.to_f / 7).floor
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

      num_lines = [n, (self.height.to_f / 16).floor].min

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
          z: self.z,
          text: @words[range],
          font: 'luximb.ttf',
          size: 12,
          x: self.x,
          y: self.y + line_num * 16
        )

        start_index = next_linebreak ? end_index + 1 : end_index
      end

      @cursor.z = self.z
      @cursor.x1 = self.x + (@lines.last ? @lines.last.text.length : 0) * 7
      @cursor.x2 = @cursor.x1
      @cursor.y1 = self.y + (num_lines.zero? ? 0 : num_lines - 1) * 16
      @cursor.y2 = self.y + (num_lines.zero? ? 1 : num_lines) * 16
    end
  end
end
