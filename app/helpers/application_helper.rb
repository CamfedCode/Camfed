module ApplicationHelper
  def time from_time
    from_time.strftime("%b %d, %Y %I:%M:%S %p")
  end
  
  
  def title a_title, render_h2=false
    content_for(:title){ "Camfed - #{a_title}" }
    content_tag(:h2, a_title) if render_h2
  end
  
  def yield_or_render(content, text)
    content_for?(content) ? content_for(content) : text
  end
  

end
