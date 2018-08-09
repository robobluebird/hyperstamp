require 'ruby2d'

module Ruby2D
  class TextBox < Rectangle
    attr_reader :words

    def initialize opts = {}
      @lines = []
      @show_border = true
      @words = opts[:text]

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

      arrange_text!
    end

    private

    def resize!
      @border.width = self.width + 2
      @border.height = self.height + 2
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

      chars_across = (self.width / 7).floor

      num_lines = [
        (@words.length.to_f / chars_across).ceil,
        (self.height.to_f / 16).floor
      ].min

      num_lines.times do |line_num|
        start_index = line_num * chars_across

        end_index = [line_num * chars_across + chars_across, @words.length].min

        range = start_index...end_index

        @lines << Text.new(
          z: self.z,
          text: @words[range],
          font: 'luximb.ttf',
          size: 12,
          color: 'black',
          x: self.x,
          y: self.y + line_num * 16)
      end
    end
  end
end
