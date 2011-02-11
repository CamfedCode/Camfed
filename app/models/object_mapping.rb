class ObjectMapping < ActiveRecord::Base
  has_many :field_mappings, :dependent => :destroy
    
  belongs_to :survey, :class_name => 'EpiSurveyor::Survey'
  
  accepts_nested_attributes_for :field_mappings
  
  
  def build_unmapped_field_mappings
    mapped_field_names = field_mappings.collect{|field| field.field_name}
    fields = Salesforce::ObjectFactory.create(self.sf_object_type).fields
    fields.each do |field|
      field_mappings.build(:field_name => field.name) unless mapped_field_names.include?(field.name)
    end
    field_mappings
  end
  
end