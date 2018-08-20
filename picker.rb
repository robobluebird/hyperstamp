module Ruby2D
  class Picker
    attr_reader :x, :y, :width, :height, :items

    def initialize opts = {}
      super opts
    end

    def to_h
      {
        type: :picker,
        x: @x,
        y: @y,
        width: @width,
        height: @height
      }
    end

    def pick item
      # someone picked something so handle it
    end
  end

  class PickerItem
    attr_reader :x, :y, :width, :height, :items, :label, :value

    def initialize opts = {}
      @picker = opts[:picker]
    end

    def pick
      @picker.pick self
    end
  end
end
