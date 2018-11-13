module Ruby2D
  class Drawing
    attr_accessor :pixels, :listener
    attr_reader :z

    def initialize opts = {}
      @z = opts[:z]
      @listener = opts[:listener]
      @visible = true

      @pixels = (opts[:pixels] || []).map do |p|
        Square.new p.merge z: @z
      end.each(&:remove)
    end

    def dont_edit
      true
    end

    def visible?
      @visible
    end

    def to_h
      {
        type: 'drawing',
        z: @z,
        pixels: @pixels.map { |pixel| { x: pixel.x, y: pixel.y, size: pixel.size, color: pixel.color.to_hex } }
      }
    end

    # do contains, mouse, etc!!

    def contains? x, y
      @pixels.find do |pixel|
        pixel.contains? x, y
      end
    end

    def z= new_z
      @z = new_z

      @pixels.each { |pixel| pixel.z = new_z }
    end

    def hover_on x, y
    end

    def hover_off x, y
    end

    def mouse_up x, y, button
    end

    def mouse_down x, y, button
    end

    def pixel? x, y
      @pixels.find { |p| p.x == x && p.y == y }
    end

    def push pixel
      pixel = pixel.merge z: @z

      @pixels << Square.new(pixel)
    end

    def pop
      if @pixels.count > 0
        @pixels.last.remove
        @pixels.pop
      end
    end

    def delete pixel
      pixel = @pixels.delete pixel
      pixel.remove if pixel
    end

    def add
      @pixels.each(&:add)
      @visible = true
    end

    def remove
      @pixels.each(&:remove)
      @visible = false
    end
  end
end
