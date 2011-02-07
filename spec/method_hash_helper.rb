def method_hash_from_hash a_hash_or_value
  if a_hash_or_value.is_a?(Array)
    return a_hash_or_value.collect{|item| method_hash_from_hash(item)}
  end

  return a_hash_or_value unless a_hash_or_value.is_a?(Hash)

  method_hash = RForce::MethodHash.new
  a_hash_or_value.each_pair do |key, value|
    method_hash[key] = method_hash_from_hash(value)
  end
  method_hash
end