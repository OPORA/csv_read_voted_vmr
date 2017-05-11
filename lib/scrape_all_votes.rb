require_relative 'get_page'
require_relative 'read_file'
require 'base32'
require_relative 'voted'

require_relative 'get_mps'

class GetAllVotes
  def self.votes(url, date)
     p url
     page = GetPage.page(url)
     page.css('.itemFullText table tr').each_with_index do |tr, index|

       colums_table = tr.css('td')
       next if colums_table[2].nil?

       number = index + 1
       name = colums_table[1].text.strip
       if colums_table[2].css('a')[0].nil?
        next if colums_table[7].css('a')[0].nil?
        doc = colums_table[7].css('a')[0][:href]
        result = colums_table[3].text.strip
       else
         next if colums_table[2].css('a')[0].nil?
         doc = colums_table[2].css('a')[0][:href]
         result = colums_table[2].text.strip
       end
       file_path = "https://www.lvivrada.gov.ua#{doc}"
       p file_path
       file_names = []
       file_name = "#{File.dirname(__FILE__)}/../files/download/#{Base32.encode(file_path)}"
       if (!File.exists?(file_name) || File.zero?(file_name))
          uri = URI.encode(file_path.gsub(/%20/,' '))
          p uri
          res = Net::HTTP.get_response(URI.parse(uri))
          if res.code == "404" and uri[/\.rtf/]
            uri = uri[/.+?\.rtf/]
            res = Net::HTTP.get_response(URI.parse(uri))
            if res.code == "404"
              uri = file_path
            end
          end
          next if res.code == "404"
          puts ">>>>  File not found, Downloading...."
          File.write(file_name, open(uri).read)
       end
       p "end load"
       file_ext = File.extname(file_path)
       if file_ext == ".rar"
         `unrar e #{file_name} #{file_name}_D/ -y`
         files = `cd #{file_name}_D && ls`
         files.split(/\n/).each do |rtf|
           file_names << "#{file_name}_D/#{rtf}"
         end
       else
         file_names << file_name
       end
       file_names.each_with_index do |file_name, i|
         if i > 0
           number = "#{number}-#{i + 1}"
         end
         ReadFile.new.rtf(file_name).each_with_index do |vot, ind|
           if ind > 0
             number = "#{number}-#{ind + 1}"
           end
           event = VoteEvent.first(name: name, date_vote: vot[:datetime], number: number, date_caden: date, rada_id: 1, option: result)
           if event.nil?
             events = VoteEvent.new(name: name, date_vote: vot[:datetime], number: number, date_caden: date, rada_id: 1, option: result)
             events.date_created = Date.today
             events.save
           else
             events = event
             events.votes.destroy!
           end
           vot[:voteds].each do |v|
             next if v.empty?
             vote = events.votes.new
             vote.voter_id = $all_mp.serch_mp(v.first)
             vote.result = short_voted_result(v.last)
             vote.save
           end
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
        ЗА: "aye",
        УТРИМАВСЯ: "abstain"
    }
    hash[:"#{result}"]
  end
end