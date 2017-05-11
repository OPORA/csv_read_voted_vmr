require 'open-uri'
require 'json'
class GetMp
  def initialize
    @data_hash = JSON.load(open('http://lvivmp.oporaua.org/'))
  end
  def serch_mp(full_name)
    p full_name
   name =full_name.gsub(/'/,'’').gsub(/ Депутатські повноваження складено/,'')
   data = @data_hash.find {|k| k["full_name"] == name  }
   return data["deputy_id"]
  end
end
