class Status

  attr_accessor :name, :error_status, :message

  def initialize(name, error_status, message)
    @name = name
    @error_status = error_status
    @message = message
  end

end