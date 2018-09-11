module Ruby2D
  class Drawing
    attr_accessor :pixels

    def initialize opts = {}
      @visible = false
    end

    def visible?
      @visible
    end
  end
end
