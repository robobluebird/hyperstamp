module StacksAndCards
  def editable?
    @stack.editable? && @card.editable?
  end

  def new_stack
    show_file_cabinet_with_text_input extension: 'stack', action: 'create_stack'
  end

  def open_stack
    show_file_cabinet extension: 'stack', action: 'load_stack'
  end

  def save_stack
    if editable?
      @card.update

      rep = JSON.pretty_generate @stack.to_h

      if @path
        File.open(@path, 'w') do |f|
          f.write rep
        end
      end

      remote_rep = HTTP.get("#{@url}/stacks/#{@stack.id}") rescue nil

      if remote_rep
        if remote_rep.status.to_i == 200
          HTTP.put("#{@url}/stacks/#{@stack.id}", rep)
        else
          HTTP.post("#{@url}/stacks")
        end
      end

      true
    else
      false
    end
  end

  def create_stack name, path
    new_stack = Stack.new name: name

    new_stack.new_card

    File.open(path, 'w') { |f| f.write JSON.pretty_generate new_stack.to_h }

    load_stack path
  end

  def load_stack path
    rep = if File.exists? path
            contents = File.read(path)
            JSON.parse(contents, symbolize_names: true) rescue {}
          else
            {}
          end

    response = HTTP.get "#{@url}/stacks/#{@stack.id}" rescue nil

    if response && response.status.to_i == 200
      remote_rep = JSON.parse response.to_s
      rep.merge remote_rep
    end

    return if rep.keys.count == 0

    unload

    @normal_rules = true

    @stack = Stack.new rep

    set title: @stack.name

    if @stack.cards.any?
      load_card 1
    else
      new_card
    end

    @path = path
  end

  def new_card
    return unless @stack.editable?

    @stack.new_card

    load_card 1
  end

  def copy_card
  end

  def paste_card
  end

  def delete_card
    if @stack && @card
      @stack.delete_card @card

      if @stack.cards.count > 0
        load_card @card.number - 1
      else
        @stack.new_card
        load_card 1
      end
    end
  end

  def next_card
    return unless @card.number < @stack.cards.count

    load_card @card.number + 1
  end

  def previous_card
    return unless @card.number > 1

    load_card @card.number - 1
  end

  def first_card
    load_card 1
  end

  def last_card
    load_card @stack.cards.count
  end

  def load_card number
    @card = @stack.card number

    card_number

    unload

    @objects += @card.render(self)

    elem = zord.reject { |o| o.is_a?(MenuItem) || o.is_a?(MenuElement) }.first

    @z = elem ? elem.z : 0

    @card
  end
end
