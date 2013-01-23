class Dictionary

  def self.save(translation_hash = {}, language = 'Swahili')
    language = 'Swahili' if language.nil?
    translation_hash.each { |key,value| 
      REDIS.set(key,value)
      REDIS.sadd(language,key)
    }
  end

  def self.get_all_translations (language = 'Swahili')
    translation_keys = REDIS.smembers(language)
    translation_hash = Hash.new
    translation_keys.each { |key|
      translation_hash[key] = REDIS.get(key)
    }
    translation_hash
  end
end