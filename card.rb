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
      klazz = Object.const_get card[:type].split('_').map(&:capitalize).join
      klazz.new obj
    end

    @pixels = opts[:pixels] || []
    @drawing = false
  end

  def editable?
    @editable
  end

  def pixel? x, y
    @pixels.find do |pixel|
      pixel.x == calc(x) && pixel.y == calc(y)
    end
  end

  def calc i
    ((i.to_f / 10).floor * 10)
  end

  def remove_pixel pixel
    @pixels.delete pixel
  end

  def pixel x, y
    { x: calc(x), y: calc(y) }
  end

  def start_drawing
    @drawing = true
  end

  def stop_drawing
    @drawing = false
  end

  def drawing?
    @drawing
  end

  def draw x, y, color, z
    return unless drawing?

    if p = pixel?(x, y)
      if p.color.to_hex != color
        p.remove

        r = remove_pixel p

        p = pixel x, y

        p = p.merge size: 10, color: color, z: z

        @pixels << Square.new(p)
      end
    else
      p = pixel x, y

      p = p.merge size: 10, color: color, z: z

      @pixels << Square.new(p)
    end
  end

  def render
    @objects.each(&:add)
    @pixels.each { |pixel| Square.new pixel }
  end

  def add object
    @objects << object
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
      objects: @objects.map(&:to_h),
      pixels: @pixels.map { |pixel| { x: pixel.x, y: pixel.y, size: pixel.size, color: pixel.to_hex } }
    }
  end
end
