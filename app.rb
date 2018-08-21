require 'ruby2d'
require 'mini_magick'
require 'json'
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

@z = -1
@item = nil
@objects = []
@mode = Mode.new
@filename = 'picker.json'
@name = nil
@created_at = nil
@updated_at = nil

set title: "..."
set background: 'white'

def write
  @updated_at = Time.now.to_i

  json = {}

  json[:name] = @name
  json[:created_at] = @created_at
  json[:updated_at] = @updated_at
  json[:cards] = [].tap do |rep|
    zord.reverse.each do |object|
      rep << object.to_h
    end
  end

  File.open(@filename, 'w') do |f|
    f.write JSON.pretty_generate json
  end
end

def read
  File.open(@filename) do |f|
    json = JSON.parse(f.read, symbolize_names: true)

    @name = json[:name]
    set title: @name

    @created_at = json[:created_at]
    @updated_at = json[:updated_at]

    json[:cards].each do |card|
      klazz = Object.const_get card[:type].split('_').map(&:capitalize).join
      @objects.push klazz.new card.merge(z: z)
    end
  end
end

def reset
  @objects = []
  @item = nil
  @mode = Mode.new

  clear
end

def load_image filename
  Dir.mkdir 'images' rescue nil

  m = MiniMagick::Image.open filename

  m.colorspace 'gray'
  m.posterize 5
  m.resize '256x256'
  m.scale '50%'
  m.scale '200%'

  path = "images/#{filename}"

  m.write path

  Graphic.new path: path, z: z
end

def closer item
  return if item.nil?

  i = zord.index(item)
  closer_index = i - 1

  return if closer_index < 0

  n = zord[closer_index]

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1

  write
end

def farther item
  return if item.nil?

  i = zord.index(item)
  n = zord[i + 1]

  return if n.nil?

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1

  write
end

def z
  @z += 1
end

def zord
  @objects.sort { |a,b| b.z <=> a.z }
end

def resizing? item, e
  ((item.x + item.width - 10)..(item.x + item.width)).cover?(e.x) &&
    ((item.y + item.height - 10)..(item.y + item.height)).cover?(e.y)
end

def new_button
  @objects << Button.new(
    z: z,
    x: 0,
    y: 20,
    width: 100,
    height: 50,
    label: 'new button')

  write
end

def new_field
  @objects << Field.new(
    z: z,
    x: 0,
    y: 20,
    width: 100,
    height: 100,
    text: '')

  write
end

def new_graphic
  # need to show a prompt for this one
end

on :mouse_down do |e|
  if @item = @menu.items.find { |o| o.contains? e.x, e.y }
    menu = true
  else
    @item = zord.find { |o| o.contains? e.x, e.y }
  end

  next unless @item

  @item.invert if @item.respond_to? :invert

  @mtype = if @mode.edit? && !menu
             resizing?(@item, e) ? :resize : :translate
           end
end

on :mouse_up do |e|
  next unless @item

  @item.revert if @item && @item.respond_to?(:revert)

  if @mtype
    write
    @mtype = nil
  else
    if @item.is_a? MenuItem
      if menu_element = @item.element_at(e.x, e.y)
        if menu_element.on_click
          instance_eval menu_element.on_click
        end
      end
    elsif @item.respond_to?(:on_click) && @item.on_click
      instance_eval @item.on_click
    end
  end

  if @mode.edit? && @item.respond_to?(:focus)
    @focused.defocus if @focused
    @item.focus
    @focused = @item
  end

  @item = nil
end

def edit_mode
  @mode.edit
  @focused = zord.first
  @focused.focus
end

def interact_mode
  @mode.interact
  @focused.defocus if @focused
  @focused = nil
end

on :mouse_move do |e|
  if @item && @mtype
    e.delta_x = 0 if (@item.x + e.delta_x < 0 && @mtype == :translate) || @item.x + @item.width + e.delta_x > get(:width) || @item.x + @item.width + e.delta_x < 0
    e.delta_y = 0 if (@item.y + e.delta_y < 20 && @mtype == :translate) || @item.y + @item.height + e.delta_y > get(:height) || @item.y + @item.height + e.delta_y < 0

    @item.send @mtype, e.delta_x, e.delta_y
  end
end

on :key_down do |e|
  if e.key.include? 'shift'
    @shift = true
  elsif e.key.include? 'command'
    @command = true
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
  end

  key = "shift_#{key}" if @shift
  key = "command_#{key}" if @command
  key = key.to_sym

  if @focused && @focused.editable?
    @focused.append key.to_s
    write
    next
  end
end

@menu = Menu.new width: get(:width)

read

show
