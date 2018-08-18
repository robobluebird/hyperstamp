require 'json'

class FontSize
  attr_reader :width, :height, :size

  def initialize opts = {}
    @width = opts[:width]
    @height = opts[:height]
    @size = opts[:size]
  end

  def to_i
    @size
  end
end

class FontDef
  attr_reader :type, :file, :sizes

  def initialize opts = {}
    @type = opts[:type]
    @file = opts[:file]
    @sizes = load_sizes opts[:sizes]
  end

  def width_for size
    @sizes.find { |s| s.size == size }.width
  end

  def height_for size
    @sizes.find { |s| s.size == size }.height
  end

  private

  def load_sizes sizes
    sizes.sort! { |a, b| a['size'] <=> b['size'] }.map do |s|
      FontSize.new size: s['size'], width: s['width'], height: s['height']
    end
  end
end

class Fonts
  @@fonts = []
  @@loaded = false

  def self.load
    fonts = File.open('fonts.json') do |f|
      JSON.parse f.read
    end

    fonts.each_pair do |font_file, sizes|
      font_def = FontDef.new(
        type: font_file.split('.').first.to_sym,
        file: font_file,
        sizes: sizes)

      @@fonts << font_def

      @@loaded = true
    end
  end

  def self.loaded?
    @@loaded
  end

  def self.all
    @@fonts
  end

  def self.types
    @@fonts.map(&:type)
  end
end

class Font
  def initialize opts = {}
    Fonts.load unless Fonts.loaded?

    self.font = (opts[:type] || :lux).to_sym
    self.size = (opts[:size] || 16).to_i
  end

  def font= type
    font_def = Fonts.all.find { |f| f.type == type }
    raise unless font_def
    @font_def = font_def
  end

  def size= num
    @size = num
  end

  def type
    @font_def.type
  end

  def file
    "fonts/#{ @font_def.file }"
  end

  def size
    @size
  end

  def width
    @font_def.width_for @size
  end

  def height
    @font_def.height_for @size
  end

  def self.types
    Fonts.load unless Fonts.loaded?
  end
end
