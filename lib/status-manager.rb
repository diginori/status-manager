require 'status-manager/status-group-manager'

module StatusManager

	def self.included(base)
		base.extend(ClassMethods)
	end

	module ClassMethods
		def attr_as_status (status_title, statuses={})
			manager_status_list[status_title] = statuses

			statuses.each do |key, value|
				#active_record scope setting
				scope "#{status_title}_#{key}", where("#{self.table_name}.#{status_title}" => value)

				#status check method
				define_method "#{status_title}_#{key}?" do 
					self.send("#{status_title}") == value
				end

				#update status
				define_method "update_#{status_title}_to_#{key}" do 
					self.update_attributes("#{status_title}" => "#{value}")
				end

				define_method "#{status_title}_to_#{key}" do 
					self.send("#{status_title}=", value)
				end
			end

			#status check method
			define_method "#{status_title}?" do |status|
				self.send("#{status_title}_#{status}?")
			end

			#status setter (do not override attr_accessible)
			define_method "#{status_title}_to" do |next_status|
				status_value = self.class.manager_status_list[status_title][next_status]
				self.send("#{status_title}=", status_value)
			end

			# update status
			define_method "update_#{status_title}" do |next_status|
				self.update_attributes(status_title.to_sym => self.class.manager_status_list[status_title][next_status])
			end

			extend StatusManager::StatusGroupManager
		end

		def manager_status_list
			status_list = {}
			begin
				status_list = self.class_variable_get('@@manager_status_list')
			rescue NameError
				self.class_variable_set('@@manager_status_list', status_list)
			end
			status_list
		end
	end
end

ActiveRecord::Base.send(:include, StatusManager) if defined? ActiveRecord
