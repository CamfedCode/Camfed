module Extended
  
  def self.extended base
    puts "extending"
  end
  
  def hello
    puts "hello"
  end
end

class MyClass
  extend Extended
end

MyClass.hello