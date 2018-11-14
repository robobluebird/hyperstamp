require 'ruby2d'
require 'mini_magick'
require 'json'
require 'filemagic'
require 'securerandom'
require 'http'
require_relative 'drawing'
require_relative 'checkbox'
require_relative 'checklist'
require_relative 'editor'
require_relative 'sketch_pad'
require_relative 'file_cabinet'
require_relative 'list'
require_relative 'label'
require_relative 'keys'
require_relative 'font'
require_relative 'graphic'
require_relative 'button'
require_relative 'mode'
require_relative 'field'
require_relative 'border'
require_relative 'menu/menu'
require_relative 'menu/menu_item'
require_relative 'menu/menu_element'
require_relative 'stack'
require_relative 'card'
require_relative 'window_ext'
require_relative 'color_ext'

require_relative 'stacks_and_cards'
require_relative 'modals'
require_relative 'modes'

include StacksAndCards
include Modals
include Modes

@url = 'http://localhost:5000'
@menu_mousing = false
@normal_rules = true
@z = 0
@item = nil
@objects = []
@mode = Mode.new
@created_at = nil
@updated_at = nil
@first_edit_click = nil
@highlighted = nil
@edited = nil
@color = '#000000'
@font = 'lux'
@font_size = 12
@path = nil

set title: "..."
set background: 'white'

def card_number
  if @card_number
    @card_number.text = "#{@card.number}/#{@stack.cards.count}"

    @card_number.x = get(:width) - @card_number.width - 5
  else
    @card_number = Label.new(
      y: 0,
      z: 4000,
      text: "#{@card.number}/#{@stack.cards.count}"
    ).add

    @card_number.x = get(:width) - @card_number.width - 5
  end
end

def unload
  interact_mode

  @objects.each { |o| o.remove unless @menu.objectify.include? o }

  @objects.select! { |o| @menu.objectify.include? o }
end

def create_menu
  @menu.remove if @menu

  @menu = Menu.new listener: self, width: get(:width)

  @objects += @menu.objectify
end

def home
  unload

  @stack = Stack.new

  @card = @stack.new_card

  new_field bordered: false, x: 0, y: 20, width: get(:width), height: 100, text: 'hyperstamp!', font: { size: 64 }
  new_field bordered: false, x: 0, y: 100, width: get(:width), height: 100, text: "get started with\nfile -> new stack", font: { size: 32 }

  @stack.editable = false

  card_number

  @stack
end

def closer
  return if @highlighted.nil?

  item = @highlighted

  i = zord.index(item)
  closer_index = i - 1

  return if closer_index < 0

  n = zord[closer_index]

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1

  save_stack
end

def farther
  return if @highlighted.nil?

  item = @highlighted

  i = zord.index(item)
  n = zord[i + 1]

  return if n.nil?

  z1 = item.z
  z2 = n.z

  item.z = z2
  n.z = z1

  save_stack
end

def z
  @z += 1
end

def cool_thing thing
  [Label, Button, Field, Checklist].include? thing.class
end

def replace_objects old, new
  @objects.reject! { |o| old.include? o }
  @objects += new
end

def zord
  @objects.sort do |a,b|
    if a.z == b.z
      if cool_thing(a) && !cool_thing(b)
        -1
      elsif !cool_thing(a) && cool_thing(b)
        1
      else
        b.z <=> a.z
      end
    else
      b.z <=> a.z
    end
  end
end

def resizing? item, e
  ((item.x + item.width - 10)..(item.x + item.width)).cover?(e.x) &&
    ((item.y + item.height - 10)..(item.y + item.height)).cover?(e.y)
end

def color= color
  @color = color
end

def color
  @color
end

def font= font
  @font = font

  @highlighted.font = font if @highlighted
end

def font
  @font
end

def font_size= font_size
  @font_size = font_size

  @highlighted.font_size = font_size if @highlighted
end

def font_size
  @font_size
end

def new_button
  return unless editable?

  @objects.push @card.add Button.new(
    z: z,
    x: 0,
    y: 20,
    width: 100,
    height: 50,
    label: 'new button',
    listener: self,
  ).add
end

def new_field opts = {}
  return unless editable?

  opts = { z: z, x: 0, y: 20, width: 100, height: 100, text: '', listener: self }.merge opts

  @objects.push @card.add Field.new(opts).add
end

def new_graphic
  return unless editable?

  show_file_cabinet intent: 'image', action: 'load_graphic'
end

def load_graphic path
  remove_file_cabinet

  Dir.mkdir 'images' rescue nil

  m = MiniMagick::Image.open path

  stored_path = File.expand_path(File.join('images', path.split('/').last))

  m.colorspace 'gray'
  m.posterize 5
  m.resize '256x256'
  m.write stored_path

  @objects.push @card.add Graphic.new(path: stored_path, z: z, x: 0, y: 20, listener: self).add
end

def menu? item
  item.is_a?(MenuItem) || item.is_a?(MenuElement)
end

on :mouse_down do |e|
  @item = zord.find { |o| o.visible? && o.contains?(e.x, e.y) }

  if menu? @item
    @menu_mousing = true
    @item.mouse_down e.x, e.y, e.button
  elsif @mode.draw?
    @card.start_drawing z
    @card.draw e.x, e.y, color
  else
    next unless @item

    @mtype = if @mode.interact?
      @item.mouse_down e.x, e.y, e.button

      nil
    else
      next if @item.respond_to? :dont_edit

      if resizing? @item, e
        :resize
      else
        :translate
      end
    end
  end
end

on :mouse_up do |e|
  if @menu_mousing
    menu_element = zord.find do |o|
      o.contains?(e.x, e.y) && o.is_a?(MenuElement) && o.visible?
    end

    if menu_element
      if @item.selectable?
        if editable?
          @item.elements.each { |me| me.deselect }
          menu_element.mouse_up e.x, e.y, e.button
          menu_element.select if @item.selectable? && editable?
        end
      else
        menu_element.mouse_up e.x, e.y, e.button
      end
    end

    @item.mouse_up e.x, e.y, e.button
    @menu_mousing = false
    save_stack
    next
  end

  @focused.defocus if @focused
  @highlighted.unhighlight if @highlighted
  @focused = nil
  @highlighted = nil

  if @mode.draw?
    @objects << @card.stop_drawing

    @already_incremented_z_for_current_drawing = false

    save_stack

    next
  end

  next unless @item

  if @mtype
    save_stack
    @mtype = nil
  end

  if @mode.edit? && @item.respond_to?(:highlight) && @normal_rules
    if @first_edit_click && Time.now.to_f - @first_edit_click < 0.20
      if @item.configurable?
        @edited = @item
        editor @item
      end
    else
      @first_edit_click = Time.now.to_f
    end

    @highlighted.unhighlight if @highlighted
    @item.highlight
    @highlighted = @item
  elsif @mode.interact?
    if @item.respond_to? :focus
      @focused.defocus if @focus
      @item.focus

      # set font/size/brush/whatever

      @focused = @item
    elsif @item.respond_to? :mouse_up
      @item.mouse_up e.x, e.y, e.button
    end
  end

  @item = nil
end

on :mouse_scroll do |e|
  x = get :mouse_x
  y = get :mouse_y

  item = zord.find { |o| o.visible? && o.contains?(x, y) && o.respond_to?(:scroll) }

  item.scroll e.delta_x, e.delta_y if item
end

on :mouse_move do |e|
  if @item && @menu_mousing
    @objects.each do |o|
      if o.contains? e.x, e.y
        if o.is_a?(MenuItem) && o != @item
          @item.mouse_up e.x, e.y, :left
          @item = o
          @item.mouse_down e.x, e.y, :left
        else
          o.hover_on e.x, e.y
        end
      else
        o.hover_off e.x, e.y
      end
    end
  elsif @mode.draw?
    @card.draw e.x, e.y, color
  elsif @item && @mtype
    if @item.is_a? Graphic
    else
      e.delta_x = 0 if (@item.x + e.delta_x < 0 && @mtype == :translate) || @item.x + @item.width + e.delta_x > get(:width) || @item.x + @item.width + e.delta_x < 0
      e.delta_y = 0 if (@item.y + e.delta_y < 20 && @mtype == :translate) || @item.y + @item.height + e.delta_y > get(:height) || @item.y + @item.height + e.delta_y < 0
    end

    @item.send @mtype, e.delta_x, e.delta_y
  else
    @objects.each do |o|
      if o.contains? e.x, e.y
        o.hover_on e.x, e.y
      else
        o.hover_off e.x, e.y
      end
    end
  end
end

def quit
  save_stack
  exit
end

on :key_down do |e|
  key = e.key.to_s

  if e.key.include? 'shift'
    @shift = true
    next
  elsif e.key.include? 'command'
    @command = true
    next
  end

  key = "shift_#{key}" if @shift
  key = "command_#{key}" if @command

  if @focused && @focused.editable?
    @focused.append key
    @held_key = key
    @key_counter = 0

    save_stack

    next
  end
end

on :key_up do |e|
  key = e.key

  if key.include? 'shift'
    @shift = false
    next
  elsif key.include? 'command'
    @command = false
    next
  elsif @highlighted && key == 'backspace'
    @highlighted.remove
    @objects.delete @card.remove @highlighted
    @highlighted.unhighlight if @highlighted
    @highlighted = nil
  else
    @held_key = nil
    @key_counter = 0
  end
end

update do
  if @held_key
    @key_counter += 1

    if @key_counter == 30 || (@key_counter > 30 && @key_counter % 5 == 0)
      @focused.append @held_key

      save_stack
    end
  end
end

create_menu

home

interact_mode

show
