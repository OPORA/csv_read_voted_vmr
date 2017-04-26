require_relative 'lib/voted'
require_relative 'lib/scrape_all_page'
desc 'Create databases'
task :create_db do
  DataMapper.auto_migrate!
end
desc 'Scrape voted'
task :scrape_voted, [:start_date, :end_date] do |t, arg|
 #p arg[:start_date]
  GetPages.new.get_votes('2017-04-06')
end
