require 'unrar'
archive = Unrar.new('81.rar')
# file = archive.list_contents.first[:filename]
# p archive.extract(file)
file_id = archive.list_contents.first[:filename]

File.open('output-name.rtf', 'w') { |file| file.write(archive.extract(file_id)) }