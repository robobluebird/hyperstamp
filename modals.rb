module Modals
  def editor item
    @er = Editor.new(
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
    @objects.reject! { |o| @er.objectify.include? o }

    @er.remove
    @er = nil

    @mode.edit
    @edited.highlight
    @highlighted = @edited
    @edited = nil

    save_stack
  end

  def show_search
    interact_mode

    @search = Search.new(
      background_height: get(:height),
      background_width: get(:width),
      listener: self,
      action: 'search'
    ).add

    @objects += @search.objectify
  end

  def remove_search
    @search.remove

    @objects.count - @objects.reject! { |o| @search.objectify.include? o }.count
  end

  def sketch_pad
    interact_mode

    @sp = SketchPad.new(
      background_height: get(:height),
      background_width: get(:width),
      listener: self,
      action: ''
    ).add

    @objects += @sp.objectify
  end

  def remove_sketch_pad
    @sp.remove

    @objects.count - @objects.reject! { |o| @sp.objectify.include? o }.count
  end

  def show_file_cabinet_with_text_input opts = {}
    interact_mode

    @normal_rules = false

    opts = {
      save: true,
      listener: self,
      background_width: get(:width),
      background_height: get(:height),
    }.merge opts

    @fc = FileCabinet.new(opts).add

    @objects += @fc.objectify
  end

  def show_file_cabinet opts = {}
    interact_mode

    @normal_rules = false

    opts = {
      listener: self,
      background_width: get(:width),
      background_height: get(:height),
    }.merge opts

    @fc = FileCabinet.new(opts).add

    @objects += @fc.objectify
  end

  def remove_file_cabinet
    @normal_rules = true

    @fc.remove

    @objects.count - @objects.reject! { |o| @fc.objectify.include? o }.count
  end
end
