class AdminusFormBuilder < ActionView::Helpers::FormBuilder

  # To pull this off we have to get a bit dirty.
  #
  # TODO: This should work fine using the label but something in our stylesheets messes this up
  # and I haven't been able to figure out what. Using a span with an onclick for now is dirty
  # but functional.
  def prompted_text_field(method, prompt, options = {})
    settings = field_settings(method, options)
    tag      = instance_tag(method).to_input_field_tag :text
    # prompt   = @template.content_tag :label, prompt, :for => get_id_from_field(tag)
    prompt   = @template.content_tag :span, prompt, :onclick => "jQuery('##{get_id_from_field(tag)}').focus();"
    
    # And now I want to remove the error wrapping.
    tag.gsub! /<(?:\/)?span(?: class="fieldWithErrors")?>/, ''

    input = @template.content_tag(:div, prompt + tag, :class => :prompted)

    render_field method, input, settings, options.reverse_merge(:inline => false, :block_wrap => true)
  end

  %w(micro tiny small medium big).each do |size|
    define_method :"#{size}_prompted_text_field" do |*args|
      options = args.extract_options!
      add_class! options, size
      prompted_text_field args.first, options
    end
  end

  def date(method, options = {})
    settings = field_settings(method, options)
    tag = instance_tag(method).to_input_field_tag :text, :class => "date_picker text"
    render_field method, tag, settings, options.reverse_merge(:inline => false)
  end

  def radio_button(method, tag_value, options = {})
    settings = field_settings(method, options)
    add_class! options, :radio
    render_field method, super, settings, options.reverse_merge(:inline => true, :reverse => true)
  end

  def check_box(method, options = {}, *args)
    settings = field_settings(method, options)
    add_class! options, :checkbox
    render_field method, super, settings, options.reverse_merge(:inline => true, :reverse => true)
  end

  def select(method, choices, options = {}, html_options = {})
    settings = field_settings(method, options)
    add_class! html_options, :styled
    render_field method, super, settings, options.reverse_merge(:inline => false)
  end
  
  # This uses the optionTree jQuery plugin to render the tree.
  def select_tree(method, tree, options = {}, html_options = {})
    field = text_field(method, options)

    # When inserting we want to reskin and when removing we want to remove the complete skinned element.
    # These rely on custom options that I inserted into optionTree in defiance of good sense or common decency.
    inserter = <<-EOJS
      function(c,s){
        s = jQuery(s);
        c = jQuery(c);
        if (c.is('input')) {
          s.insertBefore(c);
        } else {
          s.insertAfter(c.parent('.cmf-skinned-select'));
        }
        s.addClass('styled');
        s.select_skin();
      }
    EOJS
    
    remover = <<-EOJS
      function(name) {
        jQuery("select[name^='"+ name + "']").parent('.cmf-skinned-select').remove();
      }
    EOJS

    # We need to know the path to the root level to preselect the node.
    #
    # We can only work this out if the field we've got gave us a tree based ActiveRecord object.
    preselect_array =
      if method.to_s =~ /(.*)_id/ && @object.send($1).present?
        items = @object.send($1).path_to_root.reverse
        if items.present?
          items.collect(&:name) + [items.last.id]
        else
          []
        end
      else
        []
      end

    preselect = {
      get_name_from_field(field) => preselect_array
    }

    # Options hash for the option tree. Can't just use to_json as it will stringify our anonymous functions.
    tree_options = <<-EOJSON
      {
        inserter: #{inserter},
        remover: #{remover},
        preselect: #{preselect.to_json}
      }
    EOJSON
    tree_options.gsub! /\s+/, ' '

    # This JS contains all of the options for the selects
    js = "jQuery('\##{get_id_from_field(field)}').optionTree(#{build_select_tree_from(tree).to_json}, #{tree_options})"
    
    # Now we want to make it hidden
    field.gsub! /type="\s*text\s*"/, 'type="hidden"'
    
    # And write everything to the page
    field + onload_js(js)
  end
  
  def submit(*args)
    options = args.extract_options!
    text = args.first || 'Save'
    
    add_class! options, :submit

    field = super(text, options)

    # Do we add a cancel tag on?
    options.reverse_merge! :cancel => true
    
    if options[:cancel]
      options.reverse_merge! :cancel_text => 'Cancel', :cancel_url => @template.url_for(:action => :index)
      field += @template.link_to options[:cancel_text], options[:cancel_url], :onclick => 'history.go(-1); return false;', :class => :cancel
    end
    
    render_field nil, field, {}, options.reverse_merge(:inline => true)
  end
  
  %w(tiny small mid long jumbo).each do |size|
    define_method :"#{size}_submit" do |*args|
      options = args.extract_options!
      add_class! options, size
      submit args.first, options
    end
  end

  {
    :text => :text_field,
    :text_area => :text_area,
    :file_field => :file_field
  }.each do |field_type, method|
    define_method method do |*args|
      options = args.extract_options!
      value_method = args.first
      settings = field_settings(value_method, options)
      add_class! options, field_type
      render_field value_method, super(*(args << options)), settings, options.reverse_merge(:inline => false)
    end
  end

  %w(micro tiny small medium big).each do |size|
    define_method :"#{size}_text_field" do |*args|
      options = args.extract_options!
      add_class! options, size
      text_field args.first, options
    end
  end
  
  def password_field(method, options = {})
    settings = field_settings(method, options)
    add_class! options, :text
    render_field method, super(method, options.reverse_merge(:autocomplete => :off)), settings, options.reverse_merge(:inline => false)
  end
  
  %w(micro tiny small medium big).each do |size|
    define_method :"#{size}_password_field" do |*args|
      options = args.extract_options!
      add_class! options, size
      password_field args.first, options
    end
  end
  
  def wrap(options = {}, &block)
    @wrapping = true
    rendered = @template.capture(&block)
    @wrapping = false

    @template.concat wrap_field(rendered, options)
  end

  private
  
    def instance_tag(method)
      ActionView::Helpers::InstanceTag.new(@object_name, method, @template, @object)
    end

    def onload_js(string)
      @template.javascript_tag "jQuery(function(){#{string}})"
    end
  
    def get_id_from_field(string)
      string =~ /id="\s*([^"]+)\s*"/
      $1
    end
    
    def get_name_from_field(string)
      string =~ /name="\s*([^"]+)\s*"/
      $1
    end
    
    def build_select_tree_from(tree)
      returning ActiveSupport::OrderedHash.new do |hash|
        tree.each do |element|
          hash[element.name] =
            if element.children.present?
              build_select_tree_from element.children
            else
              element.id
            end

        end
      end
    end
  
    def render_field(method, field, settings, options = {})
      if options.has_key? :no_decoration
        options[:decorate] = !options.delete(:no_decoration)
      end

      options.reverse_merge! :block_wrap => false, :decorate => true
      
      label_tag =
        if settings[:label]
          label method, settings[:label]
        else
          ''
        end
      
      content =
        if options.delete(:inline) || label_tag.blank?
          [label_tag, field]
        else
          [label_tag, '<br />', field]
        end

      content = content.reverse if options.delete(:reverse)

      notes = settings[:notes] || []

      if options[:block_wrap]
        notes.shift if notes.first =~ /<br/
      end

      # Do we have any errors?
      error =
        if settings[:error]
          @template.notice_box :warning, settings[:error], :tag => :span, :dismiss => false
        else
          ''
        end

      content_pieces = [content.join(' ').html_safe, notes.join(' ').html_safe, error].reject(&:blank?)

      content =
        if options[:block_wrap]
          content_pieces.join.html_safe
        else
          content_pieces.join('<br />').html_safe
        end

      if @wrapping
        content
      elsif options.delete :decorate
        if options.delete :block_wrap
          options.reverse_merge! :wrap_tag => :div
          add_class! options, :block_wrap
        end
      
        wrap_field content, options
      else
        content
      end
    end
    
    def wrap_field(field, options = {})
      options.reverse_merge! :wrap_tag => :p
      if options.delete :required
        add_class! options, :required
        @template.widget_form_has_requires!
      end
      @template.content_tag options.delete(:wrap_tag), field, options
    end
  
    def field_settings(method, options = {})
      options.reverse_merge! :label => @object.class.human_attribute_name(method)

      field_name = "#{@object_name}_#{method.to_s}"
      label      = options.delete :label

      notes = []
      
      error = nil
      unless options.delete(:hide_errors)
        all_errors = Array.wrap @object.errors[method]
        error = all_errors.to_sentence.capitalize if all_errors.present?
      end

      if options[:note]
        notes << note(options[:note])
        options.delete :note
      elsif options[:notes]
        notes += options[:notes].collect { |n| note n }
        options.delete :notes
      end

      { :name => field_name, :label => label, :notes => notes, :options => options, :error => error }
    end
    
    def note(text, options = {})
      add_class! options, :note
      @template.content_tag :span, text, options
    end

    def add_class!(options, class_name)
      options[:class] = (options[:class] || '').to_s
      options[:class] << " #{class_name}" unless options[:class] =~ /\b#{class_name}\b/
    end

end
