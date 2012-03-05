class Dictionary

  def self.save(translation_hash = {})
    translation_hash.each{|key,value| REDIS.set(key,value)}
  end

  def self.get_all_translations
    translation_keys = REDIS.keys
    translation_hash = Hash.new
    translation_keys.each { |key|
      translation_hash[key] = REDIS.get(key)
    }
    translation_hash
  end
end