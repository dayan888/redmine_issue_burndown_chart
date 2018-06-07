module Remain
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      controller = context[:controller]
      if controller.controller_name == 'issues' && %w(index show edit new).include?(controller.action_name) || controller.controller_name == 'queries' 
        controller.send(:render_to_string, {
          :partial => "hooks/remain",
          :locals => {:context => context}
        })
      end
    end
  end
end
