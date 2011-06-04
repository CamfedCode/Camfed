def bang my_string
  a_str = my_string
  
  a_str = a_str.gsub /hi/, "XX"
end

welcome = 'hi there'

p bang(welcome)
p welcome