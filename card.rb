class Card
  attr_reader :created_at, :updated_at, :objects, :number
  attr_accessor :number, :editable

  def initialize opts = {}
    @stack = opts[:stack]
    @number = opts[:number] || 0
    @editable = opts[:editable].nil? ? true : opts[:editable]

    t = Time.now.to_i
    @created_at = opts[:created_at] || t
    @updated_at = opts[:updated_at] || t

    @objects = (opts[:objects] || []).map do |obj|
      klazz = Object.const_get obj[:type].split('_').map(&:capitalize).join
      klazz.new obj
    end

    @drawing = false
  end

  def editable?
    @editable
  end

  def drawings
    @objects.select { |o| o.is_a? Drawing }.sort_by { |o| o.z }
  end

  def pixel? x, y
    found_drawing = nil
    found_pixel = nil

    drawings.each do |drawing|
      if pixel = drawing.pixel?(calc(x), calc(y))
        found_drawing = drawing
        found_pixel = pixel

        break
      end
    end

    [found_drawing, found_pixel] if found_drawing && found_pixel
  end

  def calc i
    ((i.to_f / 10).floor * 10)
  end

  def pixel x, y
    { x: calc(x), y: calc(y) }
  end

  def start_drawing z
    @drawing = true
    @objects << Drawing.new(z: z)
  end

  def stop_drawing
    @drawing = false
    drawings.last
  end

  def drawing?
    @drawing
  end

  def draw x, y, color
    return unless drawing?

    drawing, pixel = pixel?(x, y)

    if pixel
      if pixel.color.to_hex != color
        drawing.delete pixel

        pixel = pixel x, y

        pixel = pixel.merge size: 10, color: color

        drawings.last.push pixel
      end
    else
      pixel = pixel x, y

      pixel = pixel.merge size: 10, color: color

      drawings.last.push pixel
    end
  end

  def render listener
    @objects.each do |o|
      o.listener = listener
      o.add
    end
  end

  def update time = nil
    time = time || Time.now.to_i
    @updated_at = time
    @stack.update time
  end

  def add object
    @objects << object
    @updated_at = Time.now.to_i
    @stack.update @updated_at
    object
  end

  def remove object
    @objects.delete object
    @updated_at = Time.now.to_i
    @stack.update @updated_at
    object
  end

  def to_h
    {
      number: @number,
      editable: @editable,
      created_at: @created_at,
      updated_at: @updated_at,
      objects: @objects.map(&:to_h)
    }
  end
end
