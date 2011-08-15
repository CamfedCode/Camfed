class ObjectMapping < ActiveRecord::Base
  has_many :field_mappings, :dependent => :destroy
    
  belongs_to :survey, :class_name => 'EpiSurveyor::Survey', :touch => :mapping_last_modified_at

  validates :salesforce_object_name, :presence => true
  
  accepts_nested_attributes_for :field_mappings
  
  def build_unmapped_field_mappings
    mapped_field_names = field_mappings.collect{|field| field.field_name}
    fields = Salesforce::Base.where(:name => self.salesforce_object_name).first.salesforce_fields
    fields.each do |field|
      field_mappings.build(:field_name => field.name) unless mapped_field_names.include?(field.name)
    end
    field_mappings
  end
  
  def deep_clone
    cloned_object_mapping = clone
    cloned_object_mapping.survey_id = nil
    
    field_mappings.each do |field_mapping|      
      cloned_object_mapping.field_mappings << field_mapping.deep_clone
    end
    
    cloned_object_mapping
  end
end
