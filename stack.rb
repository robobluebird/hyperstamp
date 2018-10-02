class Stack
  attr_reader :name, :created_at, :updated_at, :cards

  def initialize opts = {}
    t = Time.now.to_i

    @name = opts[:name] || 'default'
    @created_at = opts[:created_at] || t
    @updated_at = opts[:updated_at] || t
    @cards = (opts[:cards] || []).map { |card| Card.new card }
    @number = @cards.count
  end

  def number
    @number += 1
  end

  def new_card
    card = Card.new(stack: self, number: number)
    @cards << card
    @updated_at = @cards.last.updated_at
    card
  end

  def update time = nil
    @updated_at = time || Time.now.to_i
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
