module Ruby2D
  class Mode
    def initialize
      @mode = :interact
    end

    def edit
      @mode = :edit
    end

    def edit?
      @mode == :edit
    end

    def interact
      @mode = :interact
    end

    def interact?
      @mode == :interact
    end

    def draw
      @mode = :draw
    end

    def draw?
      @mode == :draw
    end
  end
end
