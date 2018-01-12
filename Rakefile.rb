require_relative 'lib/voted'
require_relative 'lib/scrape_all_votes'
desc 'Create databases'
task :create_db do
  DataMapper.auto_migrate!
end
desc 'Scrape voted'
task :scrape_voted, [:start_date, :end_date] do |t, arg|
 #if arg[:start_date].nil?
   GetAllVotes.new.get_all_votes
 #elsif !arg[:end_date].nil?
   #GetPages.new.get_filter_votes(arg[:start_date], arg[:end_date])
 #else
   #GetPages.new.get_filter_start_votes(arg[:start_date])
 #end
end
