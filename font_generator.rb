sizes = [8, 12, 16, 20, 24, 32, 64, 128]
fonts = Dir.children('fonts')
fonts.keep_if { |f| f.split('.').last == 'ttf' }
out = {}

fonts.each do |font|
  s = []

  sizes.each do |size|
    t = Text.new text: ' ', x: 0, y: 0, font: "fonts/#{font}", size: size, color: 'black'
    s << { size: size, width: t.width, height: t.height }
    t.remove
    t = nil
  end

  out[font] = s
end

File.open('fonts.json', 'w') do |f|
  f.write JSON.pretty_generate out
end
