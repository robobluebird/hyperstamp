class Card
  attr_reader :number, :created_at, :updated_at, :objects

  def intialize opts = {}
    @stack = opts[:stack]
    @number = opts[:number] || 0

    t = Time.now.to_i
    @created_at = opts[:created_at] || t
    @updated_at = opts[:updated_at] || t

    @objects = (opts[:objects] || []).map do |obj|
      klazz = Object.const_get card[:type].split('_').map(&:capitalize).join
      klazz.new obj
    end
  end

  def add object
    @objects << object
    @updated_at = Time.now.to_i
    @stack.update
  end

  def to_h
    {
      number: @number,
      created_at: @created_at,
      updated_at: @updated_at,
      objects: @objects.map(&:to_h)
    }
  end
end
