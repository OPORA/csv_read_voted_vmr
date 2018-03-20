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
     Dir.glob("#{File.dirname(__FILE__)}/../files/*").each do |f|

       hash << { path: f, date:  f[/\d\d.\d\d.\d\d/] }
     end
     return hash
   end
  def get_all_votes
    @all_file.each do |f|
      read_file(f[:path] )
      FileUtils.mv(f[:path], "#{File.dirname(__FILE__)}/../files_ap/")
    end
  end
  def read_file(file)

    json = File.open(file)
    file = open(json).read

    my_hash = JSON.parse(file)
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