require 'yomu'
class ReadFile
  def rtf(file_name)
    vote = {}
    yomu = Yomu.new file_name
    vote[:datetime] = yomu.text[/^від.+/].gsub(/від/,'').strip
    vote[:name] = yomu.text.split(/\n/).find{|str| str.strip[/^\d+\.\s/]}.strip.gsub(/^\d+\.\s/,'').strip
    vote[:voteds] = []
    paragraf =  yomu.text.gsub(/\n/, '\n')
     paragraf[/Вибір.+УСЬОГО:/].gsub(/\s{2,}/, ' ').gsub(/(Вибір|УСЬОГО:)/,'').split(/\\n/).each do |v|
       next if v.strip.size==0
       voted = v.strip
       if voted[/\d+/]
         vote[:voteds] << []
       else
         vote[:voteds].last << voted
       end
     end
    return vote
  end
end
