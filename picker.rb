require 'ruby2d'

module Ruby2D
  class Picker < Rectangle
    attr_reader :items

    def initialize opts = {}
      super opts
    end

    def pick item
      # someone picked something so handle it
    end
  end

  class PickerItem < Rectangle
    attr_reader :label, :value

    def initialize opts = {}
      @picker = opts[:picker]
    end

    def pick
      @picker.pick self
    end
  end
end
