require 'ruby2d'
require 'mini_magick'
require 'json'
require 'filemagic'
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

module Ruby2D
  class Window
    def mouse_callback(type, button, direction, x, y, delta_x, delta_y)
      # All mouse events
      @events[:mouse].dup.each do |id, e|
        e.call(MouseEvent.new(type, button, direction, x, y, delta_x, delta_y))
      end

      case type
      # When mouse button pressed
      when :down
        @events[:mouse_down].dup.each do |id, e|
          e.call(MouseEvent.new(type, button, nil, x, y, nil, nil))
        end
      # When mouse button released
      when :up
        @events[:mouse_up].dup.each do |id, e|
          e.call(MouseEvent.new(type, button, nil, x, y, nil, nil))
        end
      # When mouse motion / movement
      when :scroll
        @events[:mouse_scroll].dup.each do |id, e|
          e.call(MouseEvent.new(type, nil, direction, x, y, delta_x, delta_y))
        end
      # When mouse scrolling, wheel or trackpad
      when :move
        @events[:mouse_move].dup.each do |id, e|
          e.call(MouseEvent.new(type, nil, nil, x, y, delta_x, delta_y))
        end
      end
    end
  end
end

@z = -1
@item = nil
@objects = []
@mode = Mode.new
@filename = 'test.json'
@name = nil
@created_at = nil
@updated_at = nil

set title: "..."
set background: 'white'

def write
  @card.updated_at = Time.now.to_i

  File.open(@filename, 'w') do |f|
    f.write JSON.pretty_generate @stack.to_h
  end
end

def read
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
end

def reset
  @objects = []
  @item = nil
  @mode = Mode.new

  clear
end

def load_graphic filename
  @menu.activate
  @fc.remove if @fc

  Dir.mkdir 'images' rescue nil

  m = MiniMagick::Image.open filename

  m.colorspace 'gray'
  m.posterize 5
  m.resize '256x256'
  m.scale '50%'
  m.scale '200%'

  path = File.expand_path(File.join('images', filename.split('/').last))

  p path

  m.write path

  @objects << Graphic.new(path: path, z: z).add
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

# how do we intercept mouse events and stop them at an element level?
def z
  if @mode.draw?
    if @incd
      @z
    else
      @incd = true
      @z += 1
    end
  else
    @z += 1
  end
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
    label: 'new button').add

  # write
end

def new_field
  @objects << Field.new(
    z: z,
    x: 0,
    y: 20,
    width: 100,
    height: 100,
    text: '').add

  # write
end

def new_graphic
  # launch file cabinet with image intent
  # get file_path back if cool
  # load_image file_path

  @fc = FileCabinet.new(
    intent: :image,
    listener: self,
    background_width: get(:width),
    background_height: get(:height),
    action: 'load_graphic'
  ).add

  @menu.deactivate
end

@drawings = []
@drawing = false

def calc i
  ((i.to_f / 10).floor * 10)
end

def pixel? x, y
  @drawings.find do |drawing|
    drawing.find do |pixel|
      pixel.x == calc(x) && pixel.y == calc(y)
    end
  end
end

def pixel x, y
  { x: calc(x), y: calc(y) }
end

def maybe_draw x, y
  return unless @drawing

  unless pixel? x, y
    p = pixel x, y
    p = p.merge size: 10, color: 'black', z: z

    @drawings.last << Square.new(p)
  end
end

on :mouse_down do |e|
  if @mode.draw?
    @drawings << []
    @drawing = true
    maybe_draw e.x, e.y
  else
    if @item = @menu.items.find { |o| o.contains? e.x, e.y }
      menu = true
    else
      @item = zord.find { |o| o.contains? e.x, e.y }
    end

    next unless @item

    @mtype = if @mode.edit? && !menu
               resizing?(@item, e) ? :resize : :translate
             end
  end
end

on :mouse_up do |e|
  if @mode.draw?
    @drawing = false
    @incd = false
    pp @drawings.map { |drawing| drawing.count }
    pp @drawings.map { |drawing| drawing.map(&:z).uniq }
    next
  end

  @focused.defocus if @focused
  @highlighted.unhighlight if @highlighted
  @focused = nil
  @highlighted = nil

  next unless @item

  if @mtype
    # write
    @mtype = nil
  end

  if @mode.edit? && @item.respond_to?(:highlight)
    @highlighted.unhighlight if @highlighted
    @item.highlight
    @highlighted = @item
  elsif @mode.interact? && @item.respond_to?(:focus)
    @focused.defocus if @focus
    @item.focus
    @focused = @item
  end

  @item = nil
end

on :mouse_move do |e|
  if @mode.draw?
    maybe_draw e.x, e.y
  elsif @item && @mtype
    e.delta_x = 0 if (@item.x + e.delta_x < 0 && @mtype == :translate) || @item.x + @item.width + e.delta_x > get(:width) || @item.x + @item.width + e.delta_x < 0
    e.delta_y = 0 if (@item.y + e.delta_y < 20 && @mtype == :translate) || @item.y + @item.height + e.delta_y > get(:height) || @item.y + @item.height + e.delta_y < 0

    @item.send @mtype, e.delta_x, e.delta_y
  end
end

def undo
  if @mode.draw?
    @last = @drawings.pop
    @last.map(&:remove)
    @last
  end
end

def redo
  if @last
    if @last.is_a?(Array) && @last.first.is_a?(Square)
      @last.map(&:add)
      @drawings << @last
      @last = nil
    end
  end
end

def edit_mode
  @mode.edit
  @highlighted = zord.first
  @highlighted.highlight if @highlighted
end

def interact_mode
  @mode.interact
  @highlighted.unhighlight if @highlighted
  @highlighted = nil
end

def draw_mode
  @mode.draw
  @highlighted.unhighlight if @highlighted
  @highlighted = nil
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

    # write

    next
  end
end

@menu = Menu.new listener: self, width: get(:width)

#
# # @list = List.new(
# #   x: 100,
# #   y: 100,
# #   items: %w(one two three four five six seven eight nine ten eleven twelve)
# # )
# #
# # @list.add
# #
# # @b = Button.new y: 20
# # @b.add
# # @objects << @b

show
