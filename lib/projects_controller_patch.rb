require_dependency 'projects_controller'

module ProjectsControllerPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method :modules_without_burndown_plugin, :modules
            alias_method :modules, :modules_with_burndown_plugin
        end
    end

    module ClassMethods
    end

    module InstanceMethods
        def modules_with_burndown_plugin()
            ret = modules_without_burndown_plugin
            puts "Install burndown chart plugin"
	        em = EnabledModule.where(:name => 'issue_burndown_chart', :project_id => @project.id)
	        if em
	            begin
	                cf = IssueCustomField.find_by_name('RemainUmVtYWlu')
                    CustomField.connection.execute("INSERT INTO custom_fields_projects (custom_field_id, project_id) VALUES (#{cf.id}, #{@project.id})")
      	        rescue Exception => e
                    puts e
               end
	        end

	        ret
        end
    end
end

