module Ruby2D
  class Window
    def mouse_callback(type, button, direction, x, y, delta_x, delta_y)
      # All mouse events
      @events[:mouse].dup.each do |id, e|
        e.call(MouseEvent.new(type, button, direction, x, y, delta_x, delta_y))
      end

      case type
        # When mouse button pressed
      when :down
        @events[:mouse_down].dup.each do |id, e|
          e.call(MouseEvent.new(type, button, nil, x, y, nil, nil))
        end
        # When mouse button released
      when :up
        @events[:mouse_up].dup.each do |id, e|
          e.call(MouseEvent.new(type, button, nil, x, y, nil, nil))
        end
        # When mouse motion / movement
      when :scroll
        @events[:mouse_scroll].dup.each do |id, e|
          e.call(MouseEvent.new(type, nil, direction, x, y, delta_x, delta_y))
        end
        # When mouse scrolling, wheel or trackpad
      when :move
        @events[:mouse_move].dup.each do |id, e|
          e.call(MouseEvent.new(type, nil, nil, x, y, delta_x, delta_y))
        end
      end
    end
  end
end
