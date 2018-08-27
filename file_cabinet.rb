module Ruby2D
  class FileCabinet
    def initialize opts = {}
      @rendered = false
      @listener = opts[:listener]
      @background_width = opts[:background_width]
      @background_height = opts[:background_height]
      @z = 4000
    end

    def remove
      @background.remove
      @list.remove

      self
    end

    def add
      if @rendered
        @background.add
        @list.add
      else
        render!
      end

      self
    end

    def choose item
      if item.end_with? '/'
        @list.items = entries(item.split('/').first)
      else
        pp "is \"#{item}\" usable?"
      end
    end

    private

    def render!
      @background = Rectangle.new(
        z: @z,
        x: 0,
        y: 0,
        width: @background_width,
        height: @background_height,
        color: 'white'
      )

      @background.opacity = 0.5

      @list = List.new(
        listener: self,
        z: 4000,
        x: (@background_width / 2) - (@background_width / 4),
        y: (@background_height / 2) - (@background_height / 4),
        width: @background_width / 2,
        height: @background_height / 2 + 2,
        items: entries
      )

      @list.add

      @rendered = true
    end
  end

  def entries start_point = '.'
    Dir.entries(start_point).reject do |e|
      ['.'].include?(e)
    end.map do |e|
      Dir.exist?(e) ? "#{e}/" : e
    end
  end
end
