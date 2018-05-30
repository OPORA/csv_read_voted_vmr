require_relative 'voted'
require_relative 'get_mps'
require 'json'
require 'date'

class GetAllVotes
   def initialize
     @all_file = get_all_file()
     #$all_mp =  GetMp.new
   end
   def get_all_file
     hash = []
     uri = "https://opendata.drohobych-rada.gov.ua/api/3/action/package_show?id=d0580cfd-39ee-41d5-ae59-b25dd9c64439"
     json = open(uri).read
     hash_json = JSON.parse(json)
     hash_json["result"][0]["resources"].each do |f|
       next if f["url"] == "https://opendata.drohobych-rada.gov.ua/sites/default/files/deputies.json"
       p f["url"]
       hash << { path: f["url"], last_modified: f["last_modified"]}
     end
     return hash
   end
  def get_all_votes
    @all_file.each do |f|
      update = Update.first(url: f[:path], last_modified: f[:last_modified])
      if update.nil?
        read_file(f[:path] )
        Update.create(url: f[:path], last_modified: f[:last_modified])
      end
    end
  end
  def read_file(file)

    json = open(file).read

    my_hash = JSON.parse(json)
    p my_hash["sessionDate"]
    date_caden = Date.strptime(my_hash["sessionDate"],'%d.%m.%y')
    rada_id = 6

    my_hash["voting"].each_with_index  do |v, i|
      next if v["namedVoting"].empty?
      name = v["voteName"].strip
      number = i + 1
       p v["voteTimestamp"]
      date_vote =  DateTime.strptime(v["voteTimestamp"], '%d.%m.%y %H:%M:%S')
      event = VoteEvent.first(name: name, date_vote: date_vote, number: number, date_caden: date_caden, rada_id: rada_id)
      if event.nil?
        events = VoteEvent.new(name: name, date_vote: date_vote, number: number, date_caden: date_caden, rada_id: rada_id)
        events.date_created = Date.today
        events.save
      else
        events = event
        events.votes.destroy!
      end
      size = v["namedVoting"].size/2.to_f
      p size
      ages =[]
      v["namedVoting"].each do |r|
        v = r.to_a[0]
        vote = events.votes.new
        vote.voter_id = v.first #$all_mp.serch_mp(v.first)
        vote.result =  short_voted_result(v.last)
        vote.save

        if vote.result == "aye"
          ages << 1
        end
      end
      ages_sum = ages.size
      if ages_sum > size
        result = "Прийнято"
      else
        result = "Не прийнято"
      end
      events.update(option: result)
    end

  end
  def short_voted_result(result)
    hash = {
        "НЕ ГОЛОСУВАВ":  "not_voted",
        ВІДСУТНІЙ: "absent",
        ВІДСУТНЯ: "absent",
        ПРОТИ:  "against",
        ЗА: "aye",
        УТРИМАВСЯ: "abstain",
        УТРИМАЛАСЬ: "abstain"
    }
    hash[:"#{result.upcase}"]
  end
end
