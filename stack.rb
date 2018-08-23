class Stack
  attr_reader :name, :created_at, :updated_at, :cards

  def initialize opts = {}
    @name = opts[:name] || 'default'

    t = Time.now.to_i
    @created_at = opts[:created_at] || t
    @updated_at = opts[:updated_at] || t

    @cards = (opts[:cards] || []).map { |card| Card.new card }
  end

  def add
    @cards << Card.new(stack: self, number: @cards.last.number + 1)
    @updated_at = @cards.last.updated_at
    @cards.last
  end

  def update
    @updated_at = Time.now.to_i
  end

  def to_h
    {
      name: @name,
      created_at: @created_at,
      updated_at: @updated_at,
      cards: @cards.map(&:to_h)
    }
  end
end
