class FontSize
  attr_reader :type, :width, :height, :size

  def initialize opts = {}
    @type = opts[:type].to_sym
    @width = opts[:width]
    @height = opts[:height]
    @size = opts[:size]
  end

  def to_i
    @size
  end

  def to_s
    @type.to_s
  end
end

class FontDef
  attr_reader :type, :file

  def initialize opts = {}
    @type = opts[:type].to_sym
    @file = opts[:file]
  end
end

class Font
  def initialize opts = {}
    @fonts = [
      FontDef.new(type: :default, file: 'luximb.ttf')
    ]

    @sizes = [
      FontSize.new(type: 'smallest', width: 5, height: 11, size: 8),
      FontSize.new(type: 'small', width: 7, height: 16, size: 12),
      FontSize.new(type: 'default', width: 10, height: 21, size: 16),
      FontSize.new(type: 'larger', width: 12, height: 26, size: 20),
      FontSize.new(type: 'largest', width: 14, height: 31, size: 24),
      FontSize.new(type: 'monstrous', width: 19, height: 42, size: 32),
      FontSize.new(type: 'insane', width: 38, height: 79, size: 64),
      FontSize.new(type: 'planet', width: 77, height: 158, size: 128)
    ]

    self.size = (opts[:size] || :default).to_sym
    self.font = (opts[:type] || :default).to_sym
  end

  def font= word
    font = @fonts.find { |f| f.type == word }
    raise unless font
    @font = font
  end

  def type
    @font.type.to_s
  end

  def file
    @font.file
  end

  def size= word
    size = @sizes.find { |s| s.type == word }
    raise unless size
    @size = size
  end

  def size
    @size
  end

  def width
    @size.width
  end

  def height
    @size.height
  end
end
