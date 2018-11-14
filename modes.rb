module Modes
  def edit_mode
    return unless editable?

    @mode.edit
  end

  def interact_mode
    @mode.interact

    @menu.select 'tools', 'interact'

    @highlighted.unhighlight if @highlighted

    @highlighted = nil
  end

  def draw_mode
    return unless editable?

    @mode.draw

    @objects.each { |o| o.hover_off nil, nil }

    @highlighted.unhighlight if @highlighted

    @highlighted = nil
  end
end
