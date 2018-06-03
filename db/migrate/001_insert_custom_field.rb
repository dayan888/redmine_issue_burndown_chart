class InsertCustomField < ActiveRecord::Migration
  def change
    custom_field = CustomField.new_subclass_instance('IssueCustomField')
    custom_field.name = 'RemainUmVtYWlu'
    custom_field.field_format = 'float'
    custom_field.description = 'This custom field is for issue burndown chart plugin. Never delete or update while you are using it.'
    custom_field.regexp = '^[0-9¥.]+'
    custom_field.save! 

    Tracker.all.each { |t|
       CustomField.connection.execute("INSERT INTO custom_fields_trackers (custom_field_id, tracker_id) VALUES (#{custom_field.id}, #{t.id})")
    }
  end
end

