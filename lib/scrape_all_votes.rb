require_relative 'get_page'
require_relative 'read_file'
require 'base32'
require_relative 'voted'

require_relative 'get_mps'

class GetAllVotes
  def self.votes(url, date)
     p url
     page = GetPage.page(url)
     page.css('.itemFullText table tr').each do |tr|

       colums_table = tr.css('td')
       next if colums_table[2].nil?
       next if colums_table[2].css('a')[0].nil?
       number = colums_table[0].text.strip
       name = colums_table[1].text.strip
       doc = colums_table[2].css('a')[0][:href]
       result = colums_table[2].text.strip
       file_path = "https://www.lvivrada.gov.ua#{doc}"
       file_names = []
       file_name = "#{File.dirname(__FILE__)}/../files/download/#{Base32.encode(file_path)}"
       if (!File.exists?(file_name) || File.zero?(file_name))
          puts ">>>>  File not found, Downloading...."
          File.write(file_name, open(URI.encode(file_path)).read)
       end
       file_ext = File.extname(file_path)
       p file_ext
       if  file_ext == ".rtf"
         file_names << file_name
       elsif file_ext == ".rar"
         file_name
       end
       p file_name
       p file_path
       file_names.each do |file_name|
         vote = ReadFile.new.rtf(file_name)
         event = VoteEvent.first(name: name, date_vote: vote[:datetime], number: number, date_caden: date, rada_id: 1, option: result)
         if event.nil?
           events = VoteEvent.new(name: name, date_vote: vote[:datetime], number: number, date_caden: date, rada_id: 1, option: result)
           events.date_created = Date.today
           events.save
         else
           events = event
           events.votes.destroy!
         end
         vote[:voteds].each do |v|
           vote = events.votes.new
           vote.voter_id = $all_mp.serch_mp(v.first)
           vote.result = short_voted_result(v.last)
           vote.save
         end
       end
     end
     p date
  end
  def self.short_voted_result(result)
    hash = {
        "НЕ ГОЛОСУВАВ":  "not_voted",
        відсутній: "absent",
        ПРОТИ:  "against",
        ЗА: "aye"
    }
    hash[:"#{result}"]
  end
end
# $all_mp = GetMp.new
# GetAllVotes.votes("https://www.lvivrada.gov.ua/zasidannia/rezultaty-golosuvan/item/6346-rezulytaty-golosuvannya-plenarnogo-zasidannya-26-01-2017-09-02-2017", '2017-02-09' )