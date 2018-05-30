require_relative 'db'

class VoteEvent
  include DataMapper::Resource

  property :id,           Serial    # An auto-increment integer key
  property :name,         Text
  property :number,       Text
  property :rada_id,      Integer
  property :date_caden,   Date
  property :date_vote,    DateTime
  property :date_created, Date
  property :option,       String
  has n, :votes
end

class Vote
  include DataMapper::Resource

  property :id,           Serial    # An auto-increment integer key
  property :voter_id,     Integer
  property :result,       String

  belongs_to :vote_event

end

class Update
  include DataMapper::Resource
  property :id,           Serial    # An auto-increment integer key
  property :url,          String
  property :last_modified, String
end

DataMapper.finalize
