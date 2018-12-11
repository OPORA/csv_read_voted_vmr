#require_relative 'voted'
require_relative 'get_mps'
require 'json'
require 'date'
require 'open-uri'
require 'csv'
class GetAllVotes
   def initialize
     @all_file = get_all_file()
     $all_mp =  GetMp.new
   end
   def get_all_file
     hash = []
     uri = "http://opendata.gov.ua/api/3/action/resource_search?query=name:%D0%93%D0%BE%D0%BB%D0%BE%D1%81%D1%83%D0%B2%D0%B0%D0%BD%D0%BD%D1%8F"
     json = open(uri).read
     hash_json = JSON.parse(json)
     hash_json["result"]["results"].each do |f|
       #p f["url"]
       hash << { path: f["url"], last_modified: f["last_modified"], created: f["created"] }
      end
     return hash
   end
  def get_all_votes
    @all_file.each do |f|
      update = UpdatePar.first(url: f[:path], last_modified: f[:last_modified])
      if update.nil?
        read_file(f[:path], f[:created] )
        UpdatePar.create!(url: f[:path], last_modified: f[:last_modified])
      end
    end
  end
  def read_file(file, create)

    hash = []
    CSV.foreach(open(file), {headers: true, :col_sep => ';', :row_sep => "\r\n", :encoding => 'windows-1251:utf-8'})  do |row|
        h = []
        row.each do |i|
          if  i[0] == "id"
            h2 = {}
            h2[:number] = i[1]
            h2[:date_caden] = DateTime.parse(create).strftime('%Y-%m-%d')
            h << h2
          elsif i[0] == "FullAskText"
            h.last[:name] = i[1]
            h.last[:voted] = []
          elsif  i[0] == "result"
            if i[1] == "РІШЕННЯ ПРИЙНЯТО"
              h.last[:result] = "Прийнято"
            else
              h.last[:result] = "Не прийнято"
            end
          else
            next if i[0].nil?
            deputy = $all_mp.serch_mp(i[0].gsub(/\n/, ''))
            vote = short_voted_result(i[1].strip)
            h.last[:voted] << { voter_id: deputy, result: vote }
          end
        end
      hash << h
    end
    save_vote(hash)

  end
   def save_vote(hash)
     hash.each do |r|

       event = VoteEvent.first(name: r[0][:name], number: r[0][:number], date_caden:  r[0][:date_caden], rada_id: 5, option: r[0][:result])
          if event.nil?
            events = VoteEvent.new(name: r[0][:name], number: r[0][:number], date_caden:  r[0][:date_caden], rada_id: 5, option: r[0][:result])
            events.date_created = Date.today
            events.save
          else
            events = event
            events.votes.destroy!
          end

       r[0][:voted].each do |v|
           vote = events.votes.new
           vote.voter_id = v[:voter_id]
           vote.result = v[:result]
           vote.save
       end

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
#GetAllVotes.new.get_all_votes()