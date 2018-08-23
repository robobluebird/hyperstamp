# m = MiniMagick::Image.new('tape2.jpg')
# m.format 'png'
# m.resize '512x512'
# m.ordered_dither 'o3x3'
# m.depth 4
# m.colorspace 'Gray'
# m.scale '10%'
# m.scale '1000%'
# m.write 'images/tape2.png'

module Ruby2D
  class Graphic
    attr_reader :x, :y, :width, :height, :z, :path

    def initialize opts = {}
      @x = opts[:x]
      @y = opts[:y]
      @width = opts[:width]
      @height = opts[:height]
      @z = opts[:z]
      @path = opts[:path]

      @highlight = Border.new(
        z: @z,
        x: @x - 5,
        y: @y - 5,
        width: @width + 10,
        height: @height + 10,
        thickness: 5,
        color: 'blue')

      @highlight.hide

      @image = Image.new(
        path: @path,
        x: @x,
        y: @y,
        z: @z,
        width: @width,
        height: @height
      )

      @highlight.width = @image.width + 10
      @highlight.height = @image.height + 10

      @o = if @width > @height
             :l
           elsif @width < @height
             :p
           else
             :s
           end

      @r = if landscape?
             @height.to_f / @width
           elsif portrait?
             @width.to_f / @height
           else
             1.0
           end
    end

    def to_h
      {
        type: 'graphic',
        path: @path,
        x: @x,
        y: @y,
        width: @width,
        height: @height
      }
    end

    def contains? x, y
      (@image.x..(@image.x + @image.width)).cover?(x) &&
        (@image.y..(@image.y + @image.height)).cover?(y)
    end

    def z= new_z
      @highlight.z = new_z
      @image.z = new_z
    end

    def translate dx, dy
      @x = @x + dx
      @y = @y + dy

      @highlight.translate dx, dy

      @image.x = @image.x + dx
      @image.y = @image.y + dy
    end

    def highlight
      @highlight.show
    end

    def unhighlight
      @highlight.hide
    end

    def editable?
      false
    end

    def landscape?
      @o == :l
    end

    def portrait?
      @o == :p
    end

    def square?
      @o == :s
    end

    def resize dx, dy
      if !dx.to_i.zero?
        @width = @width + dx

        if landscape?
          @height = @width * @r
        elsif portrait?
          @height = @width / @r
        else
          @height = @width
        end
      else
        @height = @height + dy

        if landscape?
          @width = @height / @r
        elsif portait?
          @width = @height * @r
        else
          @width = @height
        end
      end

      @image.width = @width
      @image.height = @height

      @highlight.resize_to @width + 10, @height + 10
    end
  end
end
