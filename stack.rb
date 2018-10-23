class Stack
  attr_reader :name, :created_at, :updated_at, :cards
  attr_accessor :editable

  def initialize opts = {}
    t = Time.now.to_i

    @editable = opts[:editable].nil? ? true : opts[:editable]
    @name = opts[:name] || 'default'
    @created_at = opts[:created_at] || t
    @updated_at = opts[:updated_at] || t
    @cards = (opts[:cards] || []).map { |card| Card.new card }
    @number = @cards.count
  end

  def editable?
    @editable
  end

  def editable= editable
    @editable = editable

    @cards.each { |c| c.editable = false } if !editable
  end

  def number
    @number += 1
  end

  def new_card
    card = Card.new stack: self, number: number, editable: editable?
    @cards << card
    @updated_at = @cards.last.updated_at
    card
  end

  def delete_card card
    @card.delete card
    reindex!
  end

  def update time = nil
    @updated_at = time || Time.now.to_i
  end

  def to_h
    {
      name: @name,
      editable: @editable,
      created_at: @created_at,
      updated_at: @updated_at,
      cards: @cards.map(&:to_h)
    }
  end

  private

  def reindex!
    @number = 0

    @cards.each { |card| card.number = number }
  end
end
