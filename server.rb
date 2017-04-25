require 'sinatra'
require 'sinatra/json'
require_relative 'lib/voted'
set :protection, except: [:json_csrf]

get '/votes_events' do
  json VoteEvent.all(:fields => [:date_caden], :unique => true, :order => :date_caden.desc).map{|d| d.date_caden}
end
get '/votes_events/:date' do
  events = VoteEvent.all(date_caden: params[:date])
  json events.map{|event| [event, votes: event.votes.all.map{|v| {voter_id: v.voter_id, result: v.result}}]}

end
get '/votes_event/:id' do
  event = VoteEvent.first(:id => params[:id])
  json [event, votes: event.votes.all.map{|v| {voter_id: v.voter_id, result: v.result}}]
end
