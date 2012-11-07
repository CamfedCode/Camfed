require './app/helpers/sales_force_id_change_helper.rb'
namespace :idfix do
	desc "This task is called to update old ids with new ids in field mapping's lookup condition if ids change in Salesforce"
	task :update_ids => :environment do
		Rails.logger.info "<UPDATE_IDS_TRACE> Updating lookup condition with new district ids"
		SalesForceIdChangeHelper.update_lookup_condition_with_new_ids("district")
		Rails.logger.info "<UPDATE_IDS_TRACE> Updating lookup condition with new school ids"
		SalesForceIdChangeHelper.update_lookup_condition_with_new_ids("school")
		Rails.logger.info "<UPDATE_IDS_TRACE> Done updating lookup condition"
	end

	desc "This task will tell what all surveys have lookup condition containing the passed in value"
	task :list_surveys_with_patterns, [:pattern]  => :environment do |t, args|
		patterns = args.pattern.split(" ")
		Rails.logger.info "<UPDATE_IDS_TRACE> Fetching surveys with lookup_condition containing " + patterns.to_s
		SalesForceIdChangeHelper.list_surveys_with_lookup_condition_containing(patterns)
	end
end
