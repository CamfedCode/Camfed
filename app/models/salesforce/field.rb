module Salesforce
  class Field
    attr_accessor :name, :label, :data_type
    
    def initialize(name=nil, label=nil, data_type=nil)
      self.name = name
      self.label = label
      self.data_type = data_type
    end
    
    def ==(other)
      other.present? && self.name == other.name
    end
    
  end
end