class MappingCloneException < Exception
  def initialize(missing_fields = [])
    super(missing_fields.join(', '))
  end
end