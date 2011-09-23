class String
  def escape_single_quotes
    self.gsub(/'/, "\\\\'")
  end
end
