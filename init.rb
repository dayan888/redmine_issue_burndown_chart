Redmine::Plugin.register :redmine_issue_burndown_chart do
  name 'Issue Burndown Chart plugin'
  author 'Dayan'
  description 'This is a plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/dayan888/redmine_issue_burndown_chart'
  author_url 'https://github.com/dayan888/'

  project_module :issue_burndown_chart do
    permission :issue_burndown_chart, :issue_burndown_chart => [:index, :create, :show]
  end
  menu :project_menu, :issue_burndown_chart, { :controller => :issue_burndown_chart, :action => :index }, :caption => :label_issue_burndown_chart_menu, :param => :project_id
end

ActionDispatch::Callbacks.to_prepare do
    unless ProjectsController.included_modules.include?(ProjectsControllerPatch)
        ProjectsController.send(:include, ProjectsControllerPatch)
    end
end

require_dependency 'remain_hooks'
