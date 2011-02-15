module ApplicationHelper
  def time from_time
    from_time.strftime("%b %d, %Y %I:%M:%S %p")
  end
  
end
