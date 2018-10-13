require 'ruby2d'
require 'mini_magick'
require 'json'
require 'filemagic'
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

@z = -1
@item = nil
@objects = []
@mode = Mode.new
@created_at = nil
@updated_at = nil
@first_edit_click = nil
@highlighted = nil
@edited = nil
@color = '#000000'

set title: "..."
set background: 'white'

def write
  @card.updated_at = Time.now.to_i

  File.open(@filename, 'w') do |f|
    f.write JSON.pretty_generate @stack.to_h
  end
end

def read
  if @filename
    File.open(@filename) do |f|
      json = JSON.parse(f.read, symbolize_names: true)

      # @name = json[:name]
      # set title: @name
      #
      # @created_at = json[:created_at]
      # @updated_at = json[:updated_at]
      #
      # @cards = json[:cards].map do |card|
      #   Card.new car
      # end

      # json[:cards].each do |card|
      #   card.objects do |o|
      #     klazz = Object.const_get card[:type].split('_').map(&:capitalize).join
      #     card.objects.push klazz.new card.merge(z: z)
      #   end
      # end
    end
  else
    @stack = Stack.new
    @card = @stack.new_card
    @objects += @card.render
  end
end

def reset
  @objects = []
  @item = nil
  @mode = Mode.new

  clear
end

def closer item
  return if item.nil? && @highlighted.nil?

  i = zord.index(item)
  closer_index = i - 1

  return if closer_index < 0

  n = zord[closer_index]

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1
end

def farther item
  return if item.nil?

  i = zord.index(item)
  n = zord[i + 1]

  return if n.nil?

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1
end

def z
  if @mode.draw?
    if @already_incremented_z_for_current_drawing
      @z
    else
      @already_incremented_z_for_current_drawing = true
      @z += 1
    end
  else
    @z += 1
  end
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

def new_button
  @objects.push @card.add Button.new(z: z, x: 0, y: 20, width: 100, height: 50, label: 'new button').add
end

def new_field
  @objects.push @card.add Field.new(z: z, x: 0, y: 20, width: 100, height: 100, text: '').add
end

def new_graphic
  @fc ||= FileCabinet.new(
    intent: :image,
    listener: self,
    background_width: get(:width),
    background_height: get(:height),
    action: 'load_graphic'
  ).add

  @objects += @fc.objectify
end

def load_graphic filename
  remove_file_cabinet

  Dir.mkdir 'images' rescue nil

  m = MiniMagick::Image.open filename

  m.colorspace 'gray'
  m.posterize 5
  m.resize '256x256'
  m.scale '50%'
  m.scale '200%'

  path = File.expand_path(File.join('images', filename.split('/').last))

  m.write path

  @objects.push @card.add Graphic.new(path: path, z: z).add
end

def menu? item
  item.is_a?(MenuItem) || item.is_a?(MenuElement)
end

@menu_mousing = false

on :mouse_down do |e|
  @item = zord.find { |o| o.visible? && o.contains?(e.x, e.y) }

  if menu? @item
    @menu_mousing = true
    @item.mouse_down e.x, e.y, e.button
  elsif @mode.draw?
    @card.start_drawing
    @card.draw e.x, e.y, color, z
  else
    next unless @item

    @mtype = if @mode.interact?
      @item.mouse_down e.x, e.y, e.button

      nil
    else
      if resizing? @item, e
        :resize
      else
        :translate
      end
    end
  end
end

on :mouse_up do |e|
  @focused.defocus if @focused
  @highlighted.unhighlight if @highlighted
  @focused = nil
  @highlighted = nil

  if @menu_mousing
    menu_element = zord.find { |o| o.contains?(e.x, e.y) && o.is_a?(MenuElement) }
    menu_element.mouse_up e.x, e.y, e.button if menu_element
    @item.mouse_up e.x, e.y, e.button
    @menu_mousing = false
    next
  end

  if @mode.draw?
    @card.stop_drawing
    @already_incremented_z_for_current_drawing = false
    next
  end

  next unless @item

  if @mtype
    # write
    @mtype = nil
  end

  if @mode.edit? && @item.respond_to?(:highlight)
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
    @card.draw e.x, e.y, color, z
  elsif @item && @mtype
    e.delta_x = 0 if (@item.x + e.delta_x < 0 && @mtype == :translate) || @item.x + @item.width + e.delta_x > get(:width) || @item.x + @item.width + e.delta_x < 0
    e.delta_y = 0 if (@item.y + e.delta_y < 20 && @mtype == :translate) || @item.y + @item.height + e.delta_y > get(:height) || @item.y + @item.height + e.delta_y < 0

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

def edit_mode
  @mode.edit
end

def interact_mode
  @mode.interact

  @highlighted.unhighlight if @highlighted

  @highlighted = nil
end

def draw_mode
  @mode.draw

  @objects.each { |o| o.hover_off nil, nil }

  @highlighted.unhighlight if @highlighted

  @highlighted = nil
end

def editor item
  @er ||= Editor.new(
    background_height: get(:height),
    background_width: get(:width),
    listener: self
  )

  @er.object = @item

  @er.add

  @objects += @er.objectify

  @mode.interact
end

def remove_editor
  @er.remove

  @mode.edit
  @edited.highlight
  @highlighted = @edited
  @edited = nil

  @objects.count - @objects.reject! { |o| @er.objectify.include? o }.count
end

def sketch_pad
  @sp ||= SketchPad.new(
    background_height: get(:height),
    background_width: get(:width),
    listener: self,
    action: ''
  ).add

  @sp.add

  @objects += @sp.objectify
end

def remove_sketch_pad
  @sp.remove

  @objects.count - @objects.reject! { |o| @sp.objectify.include? o }.count
end

def remove_file_cabinet
  @fc.remove

  @objects.count - @objects.reject! { |o| @fc.objectify.include? o }.count
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

    # write

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
    end
  end
end

@menu = Menu.new listener: self, width: get(:width)

@objects += @menu.objectify

read

show
