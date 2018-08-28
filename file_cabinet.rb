module Ruby2D
  class FileCabinet
    def initialize opts = {}
      @path = Dir.pwd
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
        item = item.split('/').first

        @path = File.expand_path(File.join(@path, item))

        if Dir.exist? @path
          @list.items = entries
        else
          raise 'dad dir'
        end
      else
        # file magic
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

  def entries
    Dir.entries(@path).reject do |e|
      ['.', '.DS_Store'].include?(e)
    end.map do |e|
      Dir.exist?("#{@path}/#{e}") ? "#{e}/" : e
    end
  end
end
