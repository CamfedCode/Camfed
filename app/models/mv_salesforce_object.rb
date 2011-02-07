class MvSalesforceObject < SalesforceObject  

  def sync!
    replace_field_values_with_id
    create!
  end
  
  def self.object_type
    "Monitoring_Visit__c"
  end
  
  def replace_field_values_with_id
    self[:School__c] = MvSalesforceObject.get_first_record(:Id, :School__c, "name='#{self[:School__c]}'")
    self[:Monitor__c] = SalesforceContact.get_first_or_create(self[:Monitor__c])
    self[:TM__c] = SalesforceContact.get_first_or_create(self[:TM__c])
  end
  
  def fake_values
    self.field_values = {:Date__c => '2011-02-07',
                        :Monitor__c => 'John Doe2',
                        :Visiting_structure__c => 'CDC',
                        :School__c => 'Riversdale primary school',
                        :CPP_in_place__c => 'true',
                        :CPP_posted__c => 'true',
                        :TM_in_place__c => 'true',
                        :TM__c => 'John Doe2',#TODO
                        :People_met__c => 'head teacher',
                        :Documents_reviewed__c => 'Lesson plans;Camfed File',
                        :SNF_received__c => 'true',
                        :Amount__c => '5000.58',
                        :SNF_Receipts__c => 'true',
                        :SNF_Signatures__c => 'true',
                        :SNF_recipients_met__c => 'true',
                        :Number_met__c => '3',
                        :Fee_payments_match__c => 'true',
                        :Bank_statements__c => 'true',
                        :SNF_verified__c => 'true',
                        :Bursary_verified__c => 'true',
                        :Expenses_match_records__c => 'true'
                      }
    sync!
  end

end
