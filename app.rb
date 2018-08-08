require 'ruby2d'
require 'mini_magick'
require_relative 'graphic'
require_relative 'button'
require_relative 'mode'

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

  MyImage.new path: path, context: self, z: z
end

def closer item
  i = zord.index(item)
  n = zord[i - 1]

  return if n.nil?

  z1, z2 = item.z, n.z
  item.z = z2
  n.z = z1
end

def farther item
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
  @item.revert if @item && @item.respond_to?(:revert)

  if @mtype
    @mtype = nil
  else
    # do something with click
    # for button it'd be the click action
    # for text box it'd be focus
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

toggle = 0
gtoggle = 0
on :key_up do |e|
  if e.key.to_sym == :f
    if toggle.zero?
      closer @objects.first
      toggle = 1
    else
      farther @objects.first
      toggle = 0
    end
  elsif e.key.to_sym == :g
    if gtoggle.zero?
      @objects.first.hide_border
      gtoggle = 1
    else
      @objects.first.show_border
      gtoggle = 0
    end
  elsif e.key.to_sym == :e
    @mode.edit? ? @mode.interact : @mode.edit
  elsif e.key.to_sym == :r
    reset
  elsif e.key.to_sym == :h
    if @controls.size > 0
      @controls.each do |c|
        c.remove
      end
      @controls.clear
    else
      add_controls
    end
  end
end

def add_controls
  @controls << Button.new(
    label: 'new button',
    z: 1000,
    x: get(:width) - 110,
    y: 10,
    width: 100,
    height: 50
  )

  @controls << Button.new(
    label: 'new text',
    z: 1000,
    x: get(:width) - 110,
    y: 70,
    width: 100,
    height: 50
  )

  @controls << Button.new(
    label: 'new graphic',
    z: 1000,
    x: get(:width) - 110,
    y: 130,
    width: 100,
    height: 50
  )

  @controls << Button.new(
    label: 'closer',
    z: 1000,
    x: get(:width) - 110,
    y: 190,
    width: 100,
    height: 50
  )

  @controls << Button.new(
    label: 'farther',
    z: 1000,
    x: get(:width) - 110,
    y: 250,
    width: 100,
    height: 50
  )
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

show
