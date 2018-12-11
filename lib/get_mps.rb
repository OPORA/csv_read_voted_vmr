require 'open-uri'
require 'json'
class GetMp
  def initialize
    @data_hash = JSON.load(open('https://scrapervinnitsadeputy.herokuapp.com/'))
  end
  def serch_mp(short_name)
   data = @data_hash.find {|k| k["short_name"] == short_name  }
   return data["deputy_id"]
  end
end
