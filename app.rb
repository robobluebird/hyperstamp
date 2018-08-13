require 'ruby2d'
require 'mini_magick'
require_relative 'graphic'
require_relative 'button'
require_relative 'mode'
require_relative 'text_box'

@z = -1
@item = nil
@objects = []
@controls = []
@mode = Mode.new
@filename = nil

set title: "..."
set background: 'white'

def write
  # rep <- name

  @objects.each do |o|
    # rep <- o.serialize
  end
end

def read
  # File.open(@filename) do |f|
    # objs = JSON.parse(f.read)
    # objs.each do { |o| @objects << get_class(o).new(o.stuff) }
  # end
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

  Graphic.new path: path, context: self, z: z
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
  @z += 1
end

def zord
  @objects.sort { |a,b| b.z <=> a.z }
end

def resizing? item, e
  ((item.x + item.width - 10)..(item.x + item.width)).cover?(e.x) &&
    ((item.y + item.height - 10)..(item.y + item.height)).cover?(e.y)
end

on :mouse_down do |e|
  control = false

  @item = zord.find { |o| o.contains? e.x, e.y }

  if !@item
    @item = @controls.find { |o| o.contains? e.x, e.y }

    control = true
  end

  next unless @item

  @item.invert if @item.respond_to? :invert

  @mtype = if @mode.edit? && !control
             resizing?(@item, e) ? :resize : :translate
           end
end

on :mouse_up do |e|
  if @mode.edit? && !@controls.include?(@item)
    @focused.defocus if @focused
    @focused = nil
  end

  next unless @item

  @item.revert if @item && @item.respond_to?(:revert)

  if @mtype
    @mtype = nil
  else
    if @item.respond_to?(:on_click) && @item.on_click
      eval @item.on_click
    end
  end

  if @mode.edit? && !@controls.include?(@item)
    @item.focus
    @focused = @item
  end

  @item = nil
end

on :mouse_move do |e|
  if @item && @mtype
    e.delta_x = 0 if (@item.x + e.delta_x < 0 && @mtype == :translate) || @item.x + @item.width + e.delta_x > get(:width) || @item.x + @item.width + e.delta_x < 0
    e.delta_y = 0 if (@item.y + e.delta_y < 0 && @mtype == :translate) || @item.y + @item.height + e.delta_y > get(:height) || @item.y + @item.height + e.delta_y < 0

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
    next
  end

  if key == :g
    if @objects.first.border?
      @objects.first.hide_border
    else
      @objects.first.show_border
    end
  elsif key == :e
    if @mode.edit?
      @mode.interact
      remove_controls
    else
      @mode.edit
      add_controls
    end
  elsif key == :r
    reset
    @mode.edit
    add_controls
  elsif key == :s
    @box.style = @box.style == :default ? :text_only : :default
  elsif key == :x
    @box.color_scheme = @box.color_scheme == :black_on_white ? :white_on_black : :black_on_white
  elsif key == :h
    @box.text_color = @box.text_color == :black ? :white : :black
  end
end

def remove_controls
  @controls.each do |c|
    c.remove
  end

  @controls.clear
end

def add_controls
  x = get(:width) - 110

  @controls = [
    Button.new(label: 'new button', z: 1000, x: x, y: 10, width: 100, height: 50),
    Button.new(label: 'new text', z: 1000, x: x, y: 70, width: 100, height: 50),
    Button.new(label: 'new graphic', z: 1000, x: x, y: 130, width: 100, height: 50),
    Button.new(label: 'closer', z: 1000, x: x, y: 190, width: 100, height: 50, on_click: 'closer(@focused)'),
    Button.new(label: 'farther', z: 1000, x: x, y: 250, width: 100, height: 50, on_click: 'farther(@focused)')
  ]
end

@objects << load_image('skel.jpg')

@objects << Button.new(
  label: 'fun',
  z: z,
  x: 40,
  y: 40,
  width: 50,
  height: 50
)

@box = TextBox.new(
  z: z,
  x: 300,
  y: 300,
  width: 50,
  height: 50,
  text: 'Etiam et dapibus velit, sit amet aliquam tortor. Morbi cursus odio vitae nulla elementum, non blandit dui luctus. Maecenas in convallis mauris.'
)

@objects << @box

show
