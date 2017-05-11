require 'yomu'
class ReadFile
  def rtf(file_name)
    votes = []
    yomu = Yomu.new file_name
     if yomu.text[/\nУКРАЇНА\n\sЛЬВІВСЬКА МІСЬКА РАДА/]
       text_pages = yomu.text.split(/\nУКРАЇНА\n\sЛЬВІВСЬКА МІСЬКА РАДА/)
     elsif yomu.text[/ЛЬВІВСЬКА МІСЬКА РАДА\n\n ПОІМЕННЕ ГОЛОСУВАННЯ/]
       text_pages = yomu.text.split(/ЛЬВІВСЬКА МІСЬКА РАДА\n\n ПОІМЕННЕ ГОЛОСУВАННЯ/)
     elsif yomu.text[/ЛЬВІВСЬКА МІСЬКА РАДА\n\n ВІДКРИТЕ ГОЛОСУВАННЯ/]
       text_pages = yomu.text.split(/ЛЬВІВСЬКА МІСЬКА РАДА\n\n ВІДКРИТЕ ГОЛОСУВАННЯ/)
     else
       raise yomu.text
     end
    text_pages.each do |page|
     next if page == ""
     next if page[/^\n\s$/]
     vote = {}
     vote[:datetime] = page[/^від.+/].gsub(/від/,'').strip
     # vote[:name] = yomu.text.split(/\n/).find{|str| str.strip[/^\d+\.\s/]}.strip.gsub(/^\d+\.\s/,'').strip
     vote[:voteds] = []
     paragraf =  page.gsub(/\n/, '\n')
     paragraf[/Вибір.+(УСЬОГО:|ВСЬОГО:)/].gsub(/\s{2,}/, ' ').gsub(/(Вибір|УСЬОГО:|ВСЬОГО:)/,'').split(/\\n/).each do |v|
       next if v.strip.size==0
       voted = v.strip
       if voted[/\d+/]
         vote[:voteds] << []
       else
         vote[:voteds].last << voted
       end
     end
    votes << vote
    end
    return votes
  end
end
