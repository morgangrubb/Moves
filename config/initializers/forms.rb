# require 'adminus_form_builder'

# ActionView::Base.default_form_builder = AdminusFormBuilder

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
